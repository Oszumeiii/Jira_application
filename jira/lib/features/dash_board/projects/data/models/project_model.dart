import '../../domain/entities/project_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel extends ProjectEntity {
   ProjectModel({
    super.id,
    required super.name,
    required super.priority , 
    required super.projectType , 
    required super.sumary ,
    required super.description,
    super.ownerId,
    super.members,
    required super.status,
    required super.createdAt,
    super.updatedAt,
  });


factory ProjectModel.fromJson(Map<String, dynamic> json) {
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
    id: json['id'] ?? json['_id'],
    name: json['name'] ?? '',
    priority: json['priority'] ?? '',
    projectType: json['projectType'] ?? '',
    sumary: json['sumary'] ?? '',
    description: json['description'] ?? '',
    ownerId: json['ownerId'] ?? '',
    members: json['members'] != null ? List<String>.from(json['members']) : [],
    status: json['status'] ?? 'active',
    createdAt: parseDate(json['createdAt']),
    updatedAt: json['updatedAt'] != null ? parseDate(json['updatedAt']) : null,
  );
}



  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "priority" : priority , 
      "projectType": projectType , 
      "sumary" : sumary , 
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
      priority: priority,
      projectType: projectType,
      sumary: sumary,
      description: description,
      ownerId: ownerId,
      members: members,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
