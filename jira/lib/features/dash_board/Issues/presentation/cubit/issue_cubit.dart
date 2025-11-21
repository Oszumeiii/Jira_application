import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:jira/features/dash_board/Issues/domain/Entity/issue_entity.dart';
import 'package:jira/features/dash_board/Issues/domain/Usecase/delete_issue_usecase.dart';
import 'package:jira/features/dash_board/Issues/domain/Usecase/update_issue_usecase.dart';
import 'package:jira/features/dash_board/Issues/presentation/cubit/issue_state.dart';
import 'package:jira/features/dash_board/Issues/domain/Usecase/create_issue_usecase.dart';
import 'package:jira/features/dash_board/Issues/domain/Usecase/get_issue_by_id.dart';
import 'package:jira/features/dash_board/Issues/domain/Usecase/get_issue_by_project_usecase.dart';
import 'package:jira/features/dash_board/Issues/domain/Usecase/get_issues_by_assignee.dart';


@injectable
class IssueCubit extends Cubit<IssueState> {
  final CreateIssueUsecase createIssueUsecase;
  final GetIssueByProjectUsecase getIssueByProjectUsecase;
  final GetIssuesByAssigneeUsecase getIssuesByAssigneeUsecase;
  final GetIssueByIdUsecase getIssueByIdUsecase;
  final UpdateIssueUsecase updateIssueUsecase ; 
  final DeleteIssueUsecase deleteIssueUsecase ; 

  IssueCubit(
      this.createIssueUsecase,
      this.getIssueByProjectUsecase,
      this.getIssuesByAssigneeUsecase,
      this.getIssueByIdUsecase,
      this.updateIssueUsecase,
      this.deleteIssueUsecase
      ) : super(IssueState());

  Future<void> loadIssuesByProject(String projectId) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final issues = await getIssueByProjectUsecase(projectId);
      final todo = issues.where((issue) => issue.status == 'todo').toList();
      final inProgress = issues.where((issue) => issue.status == 'inProgress').toList();
      final done = issues.where((issue) => issue.status == 'done').toList();
      emit(state.copyWith(isLoading : false, todo: todo, inProgress: inProgress, done: done));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addIssue(issue) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final newIssue = await createIssueUsecase(issue);
      print (newIssue.id);
      print (newIssue.title);
      final updatedTodo = List.of(state.todo)..add(newIssue);
      emit(state.copyWith(isLoading: false, todo: updatedTodo));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

Future<void> updateIssue(IssueEntity issue) async {
  emit(state.copyWith(isLoading: true, error: null));
  try {

    final updatedIssue = await updateIssueUsecase(issue);

    List<IssueEntity> todo = List.of(state.todo);
    List<IssueEntity> inProgress = List.of(state.inProgress);
    List<IssueEntity> done = List.of(state.done);

    todo.removeWhere((i) => i.id == updatedIssue.id);
    inProgress.removeWhere((i) => i.id == updatedIssue.id);
    done.removeWhere((i) => i.id == updatedIssue.id);

    switch (updatedIssue.status) {
      case 'todo':
        todo.add(updatedIssue);
        break;
      case 'inProgress':
        inProgress.add(updatedIssue);
        break;
      case 'done':
        done.add(updatedIssue);
        break;
    }

    emit(state.copyWith(
      isLoading: false,
      todo: todo,
      inProgress: inProgress,
      done: done,
    ));
  } catch (e) {
    emit(state.copyWith(isLoading: false, error: e.toString()));
  }
}

Future<void> deleteIssue(String idIssue) async {
  emit(state.copyWith(isLoading: true, error: null));
  try {
    final success = await deleteIssueUsecase(idIssue);

    if (success) {
      List<IssueEntity> todo = List.of(state.todo);
      List<IssueEntity> inProgress = List.of(state.inProgress);
      List<IssueEntity> done = List.of(state.done);

      todo.removeWhere((i) => i.id == idIssue);
      inProgress.removeWhere((i) => i.id == idIssue);
      done.removeWhere((i) => i.id == idIssue);

      emit(state.copyWith(
        isLoading: false,
        todo: todo,
        inProgress: inProgress,
        done: done,
      ));
    } else {
      emit(state.copyWith(
        isLoading: false,
        error: "Failed to delete issue",
      ));
    }
  } catch (e) {
    emit(state.copyWith(isLoading: false, error: e.toString()));
  }
}

}
