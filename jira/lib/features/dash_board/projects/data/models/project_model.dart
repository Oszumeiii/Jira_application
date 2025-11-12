import '../../domain/entities/project_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel extends ProjectEntity {
  const ProjectModel({
    required super.id,
    required super.name,
    required super.description,
    required super.ownerId,
    required super.members,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Parse dữ liệu từ JSON hoặc Firestore
  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['_id'] ?? '';

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
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      ownerId: json['ownerId'] ?? '',
      members: List<String>.from(json['members'] ?? []),
      status: json['status'] ?? 'active',
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  /// Convert lại sang JSON để gửi lên backend
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "ownerId": ownerId,
      "members": members,
      "status": status,
      "createdAt": createdAt.toUtc().toIso8601String(),
      "updatedAt": updatedAt.toUtc().toIso8601String(),
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
