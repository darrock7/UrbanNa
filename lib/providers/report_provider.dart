import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urbanna/models/report.dart';

class ReportProvider with ChangeNotifier { // Add `with ChangeNotifier`
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Report> _reports = []; // Mark as final

  List<Report> get reports => _reports;

  Stream<List<Report>> getReportsStream() {
    return _firestore
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Report.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> addReport(Report report) async {
    await _firestore.collection('reports').add(report.toMap());
    notifyListeners();
  }

  Future<void> deleteReport(String id) async { // Change parameter type to `String`
    await _firestore.collection('reports').doc(id).delete();
    notifyListeners();
  }
}
