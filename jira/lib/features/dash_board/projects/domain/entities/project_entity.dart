// Define the ProjectEntity class 

class ProjectEntity {
  final String? id;
  final String name;
  final String description;
  final String? ownerId;
  final List<String>? members;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProjectEntity({
    required this.id,
    required this.name,
    required this.description,
     this.ownerId,
    required this.members,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}
