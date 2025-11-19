import '../../domain/Entity/issue_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class IssueModel extends IssueEntity {
  IssueModel({
    super.id,
    required super.projectId,
    required super.title,
    required super.summary,
    super.description,
    super.type,
    super.priority,
    super.status,
    super.assigneeId,
    super.reporterId,
    super.parentId,
    super.subTasks,
    required super.createdAt,
    super.updatedAt,
  });

  factory IssueModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      return DateTime.now();
    }

    return IssueModel(
      id: json['id'] ?? json['_id'],
      projectId: json['projectId'] ?? '',
      title: json['title'] ?? '',
      summary: json['summary'] ?? '',
      description: json['description'] as String?,
      type: json['type'] ?? 'task',
      priority: json['priority'] ?? 'Low',
      status: json['status'] ?? 'todo',
      assigneeId: json['assigneeId'] as String?,
      reporterId: json['reporterId'] as String?,
      parentId: json['parentId'] as String?,
      subTasks: json['subTasks'] != null ? List<String>.from(json['subTasks']) : [],
      createdAt: parseDate(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? parseDate(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "projectId": projectId,
      "title": title,
      "summary": summary,
      "description": description,
      "type": type,
      "priority": priority,
      "status": status,
      "assigneeId": assigneeId,
      "reporterId": reporterId,
      "parentId": parentId,
      "subTasks": subTasks,
      "createdAt": createdAt.toUtc().toIso8601String(),
      "updatedAt": updatedAt?.toUtc().toIso8601String(),
    };
  }

  IssueEntity toEntity() {
    return IssueEntity(
      id: id,
      projectId: projectId,
      title: title,
      summary: summary,
      description: description,
      type: type,
      priority: priority,
      status: status,
      assigneeId: assigneeId,
      reporterId: reporterId,
      parentId: parentId,
      subTasks: subTasks,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory IssueModel.fromEntity(IssueEntity entity) {
    return IssueModel(
      id: entity.id,
      projectId: entity.projectId,
      title: entity.title,
      summary: entity.summary,
      description: entity.description,
      type: entity.type,
      priority: entity.priority,
      status: entity.status,
      assigneeId: entity.assigneeId,
      reporterId: entity.reporterId,
      parentId: entity.parentId,
      subTasks: entity.subTasks,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
