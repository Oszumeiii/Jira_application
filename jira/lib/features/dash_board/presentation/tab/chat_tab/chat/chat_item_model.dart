class ChatItemModel {
  final String id;
  final String name;
  final String email;
  final String? photoURL;
  final bool isGroup;
  final List<String> members;
  final bool isOnline;

  ChatItemModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoURL,
    required this.isGroup,
    required this.members,
    this.isOnline = false,
  });

  factory ChatItemModel.fromJson(Map<String, dynamic> json, String id) {
    return ChatItemModel(
      id: id,
      name: json['userName'] ?? json['firstName'] ?? 'Unknown',
      email: json['email'] ?? '',
      photoURL: json['photoURL'],
      isGroup: json['isGroup'] ?? false,
      members: List<String>.from(json['members'] ?? []),
      isOnline: json['online'] ?? false,
    );
  }
}
