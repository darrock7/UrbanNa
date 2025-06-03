import 'package:cloud_firestore/cloud_firestore.dart';

class Report {
  final String? id;
  final String userId;
  final String title;
  final String type;
  final String description;
  final String location;
  final String severity;
  final DateTime timestamp;
  final int upvotes;
  final int downvotes;

  Report({
    this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.description,
    required this.location,
    required this.severity,
    DateTime? timestamp,
    this.upvotes = 0,
    this.downvotes = 0,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'type': type,
      'description': description,
      'location': location,
      'severity': severity,
      'timestamp': Timestamp.fromDate(timestamp),
      'upvotes': upvotes,
      'downvotes': downvotes,
    };
  }

  factory Report.fromMap(Map<String, dynamic> map, String id) {
    return Report(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? 'Unknown',
      type: map['type'] ?? 'Unknown',
      description: map['description'] ?? 'Unknown',
      location: map['location'] ?? 'Unknown',
      severity: map['severity'] ?? 'Low',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      upvotes: map['upvotes'] ?? 0,
      downvotes: map['downvotes'] ?? 0,
    );
  }

  Report duplicate({
    String? id,
    String? userId,
    String? title,
    String? type,
    String? description,
    String? location,
    String? severity,
    DateTime? timestamp,
    int? upvotes,
    int? downvotes,
  }) {
    return Report(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      type: type ?? this.type,
      description: description ?? this.description,
      location: location ?? this.location,
      severity: severity ?? this.severity,
      timestamp: timestamp ?? this.timestamp,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
    );
  }
}
