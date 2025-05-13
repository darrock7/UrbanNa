

class Report {
  final int? id;
  final String category; // 'Report' or 'Suggestion'
  final String type;     // 'Safety Hazard' or 'Incident'
  final String description;
  final String location; 

  Report({
    this.id,
    required this.category,
    required this.type,
    required this.description,
    required this.location,
  });

  //
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'type': type,
      'description': description,
      'location': location,
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
    );
  }
}
