// Define the ProjectEntity class 

class ProjectEntity {
  final String? id;
  final String name;
  final String priority ;
  final String sumary ; 
  final String description;
  final String? ownerId;
  final List<String>? members;
  final String projectType ; 
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProjectEntity({
    required this.id,
    required this.name,
    required this.priority , 
    required this.projectType , 
    required this.sumary , 
    required this.description,
     this.ownerId,
    required this.members,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}
