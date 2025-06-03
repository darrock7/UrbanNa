class UserModel {
  final String? id;
  final String name;
  final String email;
  final String password; // Reminder: avoid storing raw passwords
  final String profilePictureUrl;
  final List<String> reportIds;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.profilePictureUrl,
    required this.reportIds,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      reportIds: List<String>.from(data['reportIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'profilePictureUrl': profilePictureUrl,
      'reportIds': reportIds,
    };
  }

  UserModel duplicate({
    String? id,
    String? name,
    String? email,
    String? password,
    String? profilePictureUrl,
    List<String>? reportIds,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      reportIds: reportIds ?? this.reportIds,
    );
  }
}
