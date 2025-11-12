import '../../domain/entities/project_entity.dart';

class ProjectState {
  final bool isLoading;
  final bool isSuccess;
  final String errorMessage;
  final List<ProjectEntity> projects;

  const ProjectState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage = '',
    this.projects = const [],
  });

  ProjectState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    List<ProjectEntity>? projects,
  }) {
    return ProjectState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      projects: projects ?? this.projects,
    );
  }
}
