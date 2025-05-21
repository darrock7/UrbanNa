
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urbanna/models/report.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  
  factory FirestoreService() => _instance;
  
  FirestoreService._internal();

  final CollectionReference reportsCollection = 
      FirebaseFirestore.instance.collection('reports');
  
  // Get all reports as a stream for real-time updates
  Stream<List<Report>> getReportsStream() {
    return reportsCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
        });
  }
  
  // Get all reports once
  Future<List<Report>> getAllReports() async {
    final snapshot = await reportsCollection.get();
    return snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
  }
  
  // Add a new report
  Future<DocumentReference> addReport(Report report) {
    return reportsCollection.add(report.toFirestore());
  }
  
  // Update an existing report
  Future<void> updateReport(Report report) {
    if (report.firestoreId == null) {
      throw Exception('Cannot update a report without a Firestore ID');
    }
    return reportsCollection.doc(report.firestoreId).update(report.toFirestore());
  }
  
  // Delete a report
  Future<void> deleteReport(String firestoreId) {
    return reportsCollection.doc(firestoreId).delete();
  }
  
  // Get reports for specific user
  Future<List<Report>> getUserReports(String userId) async {
    final snapshot = await reportsCollection
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
  }
}

