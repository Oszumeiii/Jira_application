class IssueEntity {
  final String? id;
  final String projectId;
  final String title;
  final String summary;
  final String? description;
  final String type;
  final String priority;
  final String status;

  final String? assigneeId;
  final String? reporterId;

  final String? parentId;
  final List<String> subTasks;

  final DateTime createdAt;
  final DateTime? updatedAt;

  IssueEntity({
    this.id,
    required this.projectId,
    required this.title,
    required this.summary,
    this.description,
    this.type = "task",
    this.priority = "Low",
    this.status = "todo",
    this.assigneeId,
    this.reporterId,
    this.parentId,
    List<String>? subTasks,
    required this.createdAt,
    this.updatedAt,
  }) : subTasks = subTasks ?? [];

  IssueEntity copyWith({
    String? title,
    String? summary,
    String? description,
    String? type,
    String? priority,
    String? status,
    String? assigneeId,
    String? reporterId,
    String? parentId,
    List<String>? subTasks,
    DateTime? updatedAt,
  }) {
    return IssueEntity(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      description: description ?? this.description,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assigneeId: assigneeId ?? this.assigneeId,
      reporterId: reporterId ?? this.reporterId,
      parentId: parentId ?? this.parentId,
      subTasks: subTasks ?? this.subTasks,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
