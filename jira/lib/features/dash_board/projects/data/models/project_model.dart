import '../../domain/entities/project_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel extends ProjectEntity {
   ProjectModel({
    super.id,
    required super.name,
    required super.priority , 
    required super.projectType , 
     super.sumary ,
    required super.description,
    super.ownerId,
    super.members,
    required super.status,
    required super.createdAt,
    super.updatedAt,
    super.progress = 0.0,
  });

ProjectModel copyWith({
  String? id,
  String? name,
  String? priority,
  String? projectType,
  String? sumary,
  String? description,
  String? ownerId,
  List<String>? members,
  String? status,
  DateTime? createdAt,
  DateTime? updatedAt,
  double? progress,
}) {
  return ProjectModel(
    id: id ?? this.id,
    name: name ?? this.name,
    priority: priority ?? this.priority,
    projectType: projectType ?? this.projectType,
    sumary: sumary ?? this.sumary,
    description: description ?? this.description,
    ownerId: ownerId ?? this.ownerId,
    members: members ?? this.members,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
     progress: progress ?? this.progress,
  );
}


  factory ProjectModel.fromEntity(ProjectEntity entity) {
    return ProjectModel(
      id: entity.id,
      name: entity.name,
      priority: entity.priority,
      projectType: entity.projectType,
      sumary: entity.sumary,
      description: entity.description,
      ownerId: entity.ownerId,
      members: entity.members,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      progress: entity.progress,
    );
  }



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
    progress: (json['progress'] != null) ? (json['progress'] as num).toDouble() : 0.0,
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
      "progress": progress, 
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
      progress: progress,
    );
  }
}
