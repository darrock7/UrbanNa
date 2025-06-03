import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:urbanna/models/report.dart';

class ReportProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  final List<Report> _reports = [];

  ReportProvider({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

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

  Future<void> deleteReport(String id) async {
    await _firestore.collection('reports').doc(id).delete();
    notifyListeners();
  }

  Future<String?> getUserVoteStatus(String reportId, String userId) async {
    final voteDoc = await _firestore
        .collection('reports')
        .doc(reportId)
        .collection('votes')
        .doc(userId)
        .get();

    if (!voteDoc.exists) return null;
    return voteDoc.data()?['vote']; // 'up' or 'down'
  }

  Future<void> upvoteReport(String reportId, String userId) async {
    final reportRef = _firestore.collection('reports').doc(reportId);
    final voteRef = reportRef.collection('votes').doc(userId);
    final voteDoc = await voteRef.get();

    if (voteDoc.exists) return;

    await _firestore.runTransaction((txn) async {
      txn.update(reportRef, {'upvotes': FieldValue.increment(1)});
      txn.set(voteRef, {'vote': 'up'});
    });
  }

  Future<void> downvoteReport(String reportId, String userId) async {
    final reportRef = _firestore.collection('reports').doc(reportId);
    final voteRef = reportRef.collection('votes').doc(userId);
    final voteDoc = await voteRef.get();

    if (voteDoc.exists) return;

    await _firestore.runTransaction((txn) async {
      txn.update(reportRef, {'downvotes': FieldValue.increment(1)});
      txn.set(voteRef, {'vote': 'down'});
    });
  }

  String? currentUserId; // set this at login to track the current user
}
