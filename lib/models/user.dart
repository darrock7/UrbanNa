class UserModel {
  final String? id;
  final String name;
  final String email;
  final String profilePictureUrl;
  final List<String> reportIds;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
    required this.reportIds,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      reportIds: List<String>.from(data['reportIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'reportIds': reportIds,
    };
  }

  UserModel duplicate({
    String? id,
    String? name,
    String? email,
    String? profilePictureUrl,
    List<String>? reportIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      reportIds: reportIds ?? this.reportIds,
    );
  }
}
