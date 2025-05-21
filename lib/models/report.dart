import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String? firestoreId; // New field for Firestore document ID
  final int? id; // Keep for SQLite compatibility
  final String category; // 'Report' or 'Suggestion'
  final String type;     // 'Safety Hazard' or 'Incident'
  final String description;
  final String location; 
  final String severity;
  final String userId;   // Store user ID for report ownership
  final DateTime timestamp; // Add timestamp for sorting

  Report({
    this.firestoreId,
    this.id,
    required this.category,
    required this.type,
    required this.description,
    required this.location,
    required this.severity,
    required this.userId,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now(); 

  // For SQLite database
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'type': type,
      'description': description,
      'location': location,
      'severity': severity,
    };
  }

  // For Firestore database
  // For Firestore database
  Map<String, dynamic> toFirestore() {
    return {
      'category': category,
      'type': type,
      'description': description,
      'location': location,
      'severity': severity,
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create a Report object from a Map 
  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      category: map['category'] ?? 'Unknown',
      type: map['type'] ?? 'Unknown',
      description: map['description'] ?? 'Unknown',
      location: map['location'] ?? 'Unknown',
      severity: map['severity'] ?? 'Low',
      userId: map['userId'] ?? 'anonymous', // Default for legacy reports
      timestamp: map['timestamp'] != null 
          ? DateTime.parse(map['timestamp']) 
          : DateTime.now(),
    );
  }

  // Create a Report object from a Firestore document
  factory Report.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Report(
      firestoreId: doc.id,
      category: data['category'] ?? 'Unknown',
      type: data['type'] ?? 'Unknown',
      description: data['description'] ?? 'Unknown',
      location: data['location'] ?? 'Unknown',
      severity: data['severity'] ?? 'Low',
      userId: data['userId'] ?? 'anonymous',
      timestamp: data['timestamp'] != null 
          ? DateTime.parse(data['timestamp']) 
          : DateTime.now(),
    );
  }
}
