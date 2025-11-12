// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:jira/services/project_service.dart';
// import 'project_event.dart';
// import 'project_state.dart';

// class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
//   final ProjectService repository;

//   ProjectBloc(this.repository) : super(ProjectInitial()) {
//     on<LoadProjects>((event, emit) async {
//       emit(ProjectLoading());
//       try {
//         final projects = await repository.fetchProjects();
//         emit(ProjectLoaded(projects));
//       } catch (e) {
//         emit(ProjectError(e.toString()));
//       }
//     });

//     on<CreateProject>((event, emit) async {
//       emit(ProjectLoading());
//       try {
//        // await repository.createProject(event.name);
//         final projects = await repository.fetchProjects();
//         emit(ProjectLoaded(projects));
//       } catch (e) {
//         emit(ProjectError(e.toString()));
//       }
//     });
//   }
// }
