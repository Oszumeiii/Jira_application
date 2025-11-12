import '../../domain/entities/project_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    super.id,
    required super.name,
    required super.description,
    super.ownerId,
    super.members,
    required super.status,
    required super.createdAt,
    super.updatedAt,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
  final data = json;

  final id = data['id'] ?? data['_id'];

  DateTime parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    } else {
      return DateTime.now();
    }
  }

  return ProjectModel(
    id: id,
    name: data['name'] ?? '',
    description: data['description'] ?? '',
    ownerId: data['ownerId'],
    members: data['members'] != null ? List<String>.from(data['members']) : null,
    status: data['status'] ?? 'active',
    createdAt: parseDate(data['createdAt']),
    updatedAt: data['updatedAt'] != null ? parseDate(data['updatedAt']) : null,
  );
}


  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "ownerId": ownerId,
      "members": members,
      "status": status,
      "createdAt": createdAt.toUtc().toIso8601String(),
      "updatedAt": updatedAt?.toUtc().toIso8601String(),
    };
  }

  ProjectEntity toEntity() {
    return ProjectEntity(
      id: id,
      name: name,
      description: description,
      ownerId: ownerId,
      members: members,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
