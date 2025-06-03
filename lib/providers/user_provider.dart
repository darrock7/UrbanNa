import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:urbanna/models/user.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore;
  UserModel? _currentUser;

  UserProvider({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  UserModel? get currentUser => _currentUser;

  Future<void> loadUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      _currentUser = UserModel.fromMap(doc.data()!, doc.id);
      notifyListeners();
    }
  }

  Future<void> createUser(UserModel user) async {
    final docRef = await _firestore.collection('users').add(user.toMap());
    _currentUser = user.duplicate(id: docRef.id); // optional utility function
    notifyListeners();
  }

  Future<void> updateProfilePicture(String url) async {
    if (_currentUser == null) return;
    await _firestore.collection('users').doc(_currentUser!.id).update({
      'profilePictureUrl': url,
    });
    _currentUser = _currentUser!.duplicate(profilePictureUrl: url);
    notifyListeners();
  }

  Future<void> addReportToUser(String reportId) async {
    if (_currentUser == null) return;
    final updatedReports = [..._currentUser!.reportIds, reportId];
    await _firestore.collection('users').doc(_currentUser!.id).update({
      'reportIds': updatedReports,
    });
    _currentUser = _currentUser!.duplicate(reportIds: updatedReports);
    notifyListeners();
  }

  // Placeholder for future vote system
  Future<void> voteReport(String reportId, bool isUpvote) async {
    // Logic to update user’s vote history or update report vote count
  }
}
