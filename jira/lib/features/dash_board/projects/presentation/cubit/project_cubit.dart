import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:jira/features/dash_board/projects/data/models/project_model.dart';
import 'package:jira/features/dash_board/projects/domain/entities/project_entity.dart';
import 'package:jira/features/dash_board/projects/domain/usecases/create_project_usecase.dart';
import 'package:jira/features/dash_board/projects/domain/usecases/get_all_projects_usecase.dart';
import 'package:jira/features/dash_board/projects/domain/usecases/remove_project_usecase.dart';
import 'package:jira/features/dash_board/projects/domain/usecases/update_project_usecase.dart';
import 'project_state.dart';


@injectable
class ProjectCubit extends Cubit<ProjectState> {
  final GetAllProjectsUsecase getAllProjectsUseCase;

  final CreateProjectUseCase createProjectUseCase;

  final RemoveProjectUsecase removeProjectUsecase ; 
  
  final UpdateProjectUsecase updateProjectUsecase;

  ProjectCubit({
    required this.getAllProjectsUseCase,
    required this.createProjectUseCase,
    required this.removeProjectUsecase,
    required this.updateProjectUsecase 
  }) : super(const ProjectState());


  Future<void> loadProjects() async {
    emit(state.copyWith(isLoading: true));
    try {
      
      final projects = await getAllProjectsUseCase();
     // print(projects);
      emit(state.copyWith(isLoading: false, projects: projects));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      ));
    }
  }

  

  Future<void> createProject(ProjectEntity project) async {
    emit(state.copyWith(isLoading: true, isSuccess: false, errorMessage: ''));
    try {
      final createdProject = await createProjectUseCase(project);

      final updatedProjects = List<ProjectEntity>.from(state.projects)
        ..add(createdProject);

      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        projects: updatedProjects,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> removeProject(String idProject) async {
    emit(state.copyWith(isLoading: true, isSuccess: false, errorMessage: ''));

    try {
      await removeProjectUsecase(idProject);
      final updatedProjects = state.projects
          .where((project) => project.id != idProject)
          .toList();

      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        projects: updatedProjects,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'Failed to remove project: $e',
      ));
    }
  }


Future<void> updateProject(ProjectEntity project) async {
  emit(state.copyWith(isLoading: true, isSuccess: false, errorMessage: ''));

  try {
    final updatedProject = await updateProjectUsecase(project);
    final updatedProjects = List<ProjectEntity>.from(state.projects);
    final index = updatedProjects.indexWhere((p) => p.id == updatedProject.id);

    if (index != -1) {
      updatedProjects[index] = updatedProject; 
    } else {
      updatedProjects.add(updatedProject); 
    }

    emit(state.copyWith(
      isLoading: false,
      isSuccess: true,
      projects: updatedProjects,
    ));
  } catch (e) {
    emit(state.copyWith(
      isLoading: false,
      isSuccess: false,
      errorMessage: 'Failed to update project: $e',
    ));
  }
}

Future<void> onLeaveProject(ProjectEntity project, String userId) async {
  emit(state.copyWith(isLoading: true, isSuccess: false, errorMessage: ''));

  try {
    final updatedMembers = List<String>.from(project.members ?? [])..remove(userId);


    final projectModel = ProjectModel.fromEntity(project);
    final updatedProject = projectModel.copyWith(members: updatedMembers);


    await updateProjectUsecase(updatedProject.toEntity());

    final updatedProjects = state.projects
        .where((p) => p.id != project.id)
        .toList();

    emit(state.copyWith(
      isLoading: false,
      isSuccess: true,
      projects: updatedProjects,
    ));
  } catch (e) {
    emit(state.copyWith(
      isLoading: false,
      isSuccess: false,
      errorMessage: 'Failed to leave project: $e',
    ));
  }
}





  void resetStatus() {
    emit(state.copyWith(isSuccess: false, errorMessage: ''));
  }
}
