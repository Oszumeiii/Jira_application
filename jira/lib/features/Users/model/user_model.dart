class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final bool emailVerified;
  final String role;
  final String status;
  final String userName;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.emailVerified,
    required this.role,
    required this.status,
    required this.userName,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      emailVerified: json['emailVerified'] ?? false,
      role: json['role'] ?? '',
      status: json['status'] ?? '',
      userName: json['userName'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'emailVerified': emailVerified,
      'role': role,
      'status': status,
      'userName': userName,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}
