import 'package:cloud_firestore/cloud_firestore.dart'; 

class Report {
  final String? id;
  final String category;
  final String type;
  final String description;
  final String location;
  final String severity;
  final DateTime timestamp; // Use DateTime instead of Timestamp

  Report({
    this.id,
    required this.category,
    required this.type,
    required this.description,
    required this.location,
    required this.severity,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'type': type,
      'description': description,
      'location': location,
      'severity': severity,
      'timestamp': Timestamp.fromDate(timestamp), // Convert DateTime to Timestamp
    };
  }

  factory Report.fromMap(Map<String, dynamic> map, String id) {
    return Report(
      id: id,
      category: map['category'] ?? 'Unknown',
      type: map['type'] ?? 'Unknown',
      description: map['description'] ?? 'Unknown',
      location: map['location'] ?? 'Unknown',
      severity: map['severity'] ?? 'Low',
      timestamp: (map['timestamp'] as Timestamp).toDate(), // Convert Timestamp to DateTime
    );
  }
}
