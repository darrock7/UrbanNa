import 'dart:async';
import 'package:flutter/material.dart';
import 'package:urbanna/models/report.dart';
import 'package:urbanna/services/firestore_service.dart';
import 'package:urbanna/helpers/data_helper.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class ReportProvider with ChangeNotifier {
  List<Report> _reports = [];
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription<List<Report>>? _reportsSubscription;
  bool _isLoading = false;
  
  // Current user ID - this would come from your authentication system
  // For now, we'll use a placeholder
  String _currentUserId = 'app_user';
  
  // Getter to set current user ID (from login)
  set currentUserId(String userId) {
    _currentUserId = userId;
    notifyListeners();
  }
  
  String get currentUserId => _currentUserId;
  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;

  // Load reports from Firestore
  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Get reports from Firestore
      _reports = await _firestoreService.getAllReports();
      
      // Fallback to local if Firestore fails or is empty on first run
      if (_reports.isEmpty) {
        await _loadLocalReports();
        
        // If we have local reports but Firestore is empty, upload them
        if (_reports.isNotEmpty) {
          await _syncLocalToFirestore();
        }
      }
    } catch (e) {
      logger.e('Error loading Firestore reports: $e');
      // Fallback to local database
      await _loadLocalReports();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Load reports from local database
  Future<void> _loadLocalReports() async {
    try {
      final dbHelper = DataHelper.instance;
      final List<Map<String, dynamic>> maps = await dbHelper.queryAllReports();

      _reports = List.generate(maps.length, (i) {
        return Report.fromMap(maps[i]);
      });
    } catch (e) {
      logger.e('Error loading local reports: $e');
    }
  }
  
  // Sync local reports to Firestore (one-time operation)
  Future<void> _syncLocalToFirestore() async {
    for (var report in _reports) {
      // Add userId if it doesn't exist (for legacy reports)
      final reportWithUser = Report(
        id: report.id,
        category: report.category,
        type: report.type,
        description: report.description,
        location: report.location,
        severity: report.severity,
        userId: _currentUserId,
      );
      
      try {
        await _firestoreService.addReport(reportWithUser);
      } catch (e) {
        logger.e('Error syncing report to Firestore: $e');
      }
    }
  }
  
  // Listen to real-time updates from Firestore
  void startRealtimeUpdates() {
    logger.d("Starting realtime updates");
    _reportsSubscription?.cancel(); // Cancel any existing subscription first
    
    _reportsSubscription = _firestoreService.getReportsStream().listen(
      (reportList) {
        _reports = reportList;
        notifyListeners();
      },
      onError: (error) {
        logger.e("Error in realtime updates: $error");
      }
    );
  }
  
  // Stop listening for updates when no longer needed
  void stopRealtimeUpdates() {
    _reportsSubscription?.cancel();
    _reportsSubscription = null;
  }

  // Add a new report to both databases
  Future<void> addReport(Report report) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Add to Firestore first
      final docRef = await _firestoreService.addReport(report);
      
      // Add to local database too (as backup)
      final dbHelper = DataHelper.instance;
      await dbHelper.insertReport(report.toMap());
      
      // Refresh the reports list
      await loadReports();
    } catch (e) {
      logger.e('Error adding report: $e');
      // Add to local database only if Firestore fails
      final dbHelper = DataHelper.instance;
      await dbHelper.insertReport(report.toMap());
      await _loadLocalReports();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update an existing report
  Future<void> updateReport(Report report) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _firestoreService.updateReport(report);
      // No need to manually update _reports as we're using a stream
    } catch (error) {
      logger.e("Error updating report: $error");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete report from both databases
  Future<void> deleteReport(int id, {String? firestoreId}) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Delete from Firestore if we have the ID
      if (firestoreId != null) {
        await _firestoreService.deleteReport(firestoreId);
      } else {
        // Try to find the Firestore ID if not provided
        final reportToDelete = _reports.firstWhere((r) => r.id == id, 
          orElse: () => Report(
            id: null, 
            firestoreId: null,
            category: '', 
            type: '', 
            description: '', 
            location: '', 
            severity: '',
            userId: _currentUserId,
          ));
          
        if (reportToDelete.firestoreId != null) {
          await _firestoreService.deleteReport(reportToDelete.firestoreId!);
        }
      }
      
      // Delete from local database
      final db = await DataHelper.instance.database;
      await db.delete(
        DataHelper.tableName,
        where: '${DataHelper.columnId} = ?',
        whereArgs: [id],
      );
      
      // Update the in-memory list
      _reports.removeWhere((report) => report.id == id || report.firestoreId == firestoreId);
    } catch (e) {
      logger.e('Error deleting report: $e');
      // Try to delete locally if Firestore fails
      final db = await DataHelper.instance.database;
      await db.delete(
        DataHelper.tableName,
        where: '${DataHelper.columnId} = ?',
        whereArgs: [id],
      );
      
      _reports.removeWhere((report) => report.id == id);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Delete Firestore report using Firestore ID
  Future<void> deleteFirestoreReport(String firestoreId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _firestoreService.deleteReport(firestoreId);
      _reports.removeWhere((report) => report.firestoreId == firestoreId);
    } catch (e) {
      logger.e("Error deleting Firestore report: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    stopRealtimeUpdates();
    super.dispose();
  }
}


