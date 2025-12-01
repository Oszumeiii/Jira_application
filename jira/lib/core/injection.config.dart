// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:jira/core/api_client.dart' as _i600;
import 'package:jira/features/comment/data/remote_data_sorce/comment_remote_data_rource.dart'
    as _i456;
import 'package:jira/features/comment/data/repo_impl/comment_repo_impl.dart'
    as _i477;
import 'package:jira/features/comment/domain/repo/comment_repo.dart' as _i485;
import 'package:jira/features/comment/domain/usecase/create_comment_usecase.dart'
    as _i210;
import 'package:jira/features/comment/domain/usecase/get_comment_usecase.dart'
    as _i415;
import 'package:jira/features/comment/domain/usecase/remove_comment_usecase.dart'
    as _i37;
import 'package:jira/features/comment/presentation/cubit/comment_cubit.dart'
    as _i444;
import 'package:jira/features/dash_board/Issues/data/data_source/issue_remote_data.dart'
    as _i151;
import 'package:jira/features/dash_board/Issues/data/Repo_impl/issue_repo_impl.dart'
    as _i77;
import 'package:jira/features/dash_board/Issues/domain/Repositories/issue_repository.dart'
    as _i521;
import 'package:jira/features/dash_board/Issues/domain/Usecase/create_issue_usecase.dart'
    as _i116;
import 'package:jira/features/dash_board/Issues/domain/Usecase/delete_issue_usecase.dart'
    as _i177;
import 'package:jira/features/dash_board/Issues/domain/Usecase/get_issue_by_id.dart'
    as _i879;
import 'package:jira/features/dash_board/Issues/domain/Usecase/get_issue_by_project_usecase.dart'
    as _i492;
import 'package:jira/features/dash_board/Issues/domain/Usecase/get_issues_by_assignee.dart'
    as _i211;
import 'package:jira/features/dash_board/Issues/domain/Usecase/update_issue_usecase.dart'
    as _i385;
import 'package:jira/features/dash_board/Issues/presentation/cubit/issue_cubit.dart'
    as _i390;
import 'package:jira/features/dash_board/projects/data/data_source/project_remote_datasource.dart'
    as _i355;
import 'package:jira/features/dash_board/projects/data/repositories_impl/project_repository_impl.dart'
    as _i77;
import 'package:jira/features/dash_board/projects/domain/repositories/project_repository.dart'
    as _i688;
import 'package:jira/features/dash_board/projects/domain/usecases/create_project_usecase.dart'
    as _i644;
import 'package:jira/features/dash_board/projects/domain/usecases/get_all_projects_usecase.dart'
    as _i760;
import 'package:jira/features/dash_board/projects/domain/usecases/remove_project_usecase.dart'
    as _i134;
import 'package:jira/features/dash_board/projects/domain/usecases/update_project_usecase.dart'
    as _i723;
import 'package:jira/features/dash_board/projects/presentation/cubit/project_cubit.dart'
    as _i32;
import 'package:jira/features/login_signup/domain/cubit/AuthCubit.dart'
    as _i815;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.singleton<_i600.ApiClient>(() => _i600.ApiClient());
    gh.lazySingleton<_i815.AuthCubit>(() => _i815.AuthCubit());
    gh.factory<_i151.IssueRemoteDataSource>(
        () => _i151.IssueRemoteDataSourceImpl());
    gh.factory<_i355.ProjectRemoteDataSource>(
        () => _i355.ProjectRemoteDataSourceImpl());
    gh.factory<_i456.CommentRemoteDataSource>(
        () => _i456.CommentRemoteDataSourceImpl());
    gh.factory<_i521.IssueRepository>(
        () => _i77.IssueRepoImpl(gh<_i151.IssueRemoteDataSource>()));
    gh.factory<_i485.CommentRepository>(() => _i477.CommentRepositoryImpl(
        remoteDataSource: gh<_i456.CommentRemoteDataSource>()));
    gh.factory<_i211.GetIssuesByAssigneeUsecase>(
        () => _i211.GetIssuesByAssigneeUsecase(gh<_i521.IssueRepository>()));
    gh.factory<_i116.CreateIssueUsecase>(
        () => _i116.CreateIssueUsecase(gh<_i521.IssueRepository>()));
    gh.factory<_i492.GetIssueByProjectUsecase>(
        () => _i492.GetIssueByProjectUsecase(gh<_i521.IssueRepository>()));
    gh.factory<_i879.GetIssueByIdUsecase>(
        () => _i879.GetIssueByIdUsecase(gh<_i521.IssueRepository>()));
    gh.factory<_i385.UpdateIssueUsecase>(
        () => _i385.UpdateIssueUsecase(gh<_i521.IssueRepository>()));
    gh.factory<_i177.DeleteIssueUsecase>(
        () => _i177.DeleteIssueUsecase(gh<_i521.IssueRepository>()));
    gh.factory<_i37.DeleteCommentUseCase>(() =>
        _i37.DeleteCommentUseCase(repository: gh<_i485.CommentRepository>()));
    gh.factory<_i415.GetCommentsByTaskUseCase>(() =>
        _i415.GetCommentsByTaskUseCase(
            repository: gh<_i485.CommentRepository>()));
    gh.factory<_i210.CreateCommentUseCase>(() =>
        _i210.CreateCommentUseCase(repository: gh<_i485.CommentRepository>()));
    gh.factory<_i444.CommentCubit>(() => _i444.CommentCubit(
          gh<_i415.GetCommentsByTaskUseCase>(),
          gh<_i210.CreateCommentUseCase>(),
          gh<_i37.DeleteCommentUseCase>(),
        ));
    gh.factory<_i688.ProjectRepository>(
        () => _i77.ProjectRepositoryImpl(gh<_i355.ProjectRemoteDataSource>()));
    gh.factory<_i134.RemoveProjectUsecase>(
        () => _i134.RemoveProjectUsecase(gh<_i688.ProjectRepository>()));
    gh.factory<_i760.GetAllProjectsUsecase>(
        () => _i760.GetAllProjectsUsecase(gh<_i688.ProjectRepository>()));
    gh.factory<_i644.CreateProjectUseCase>(
        () => _i644.CreateProjectUseCase(gh<_i688.ProjectRepository>()));
    gh.factory<_i723.UpdateProjectUsecase>(
        () => _i723.UpdateProjectUsecase(gh<_i688.ProjectRepository>()));
    gh.factory<_i390.IssueCubit>(() => _i390.IssueCubit(
          gh<_i116.CreateIssueUsecase>(),
          gh<_i492.GetIssueByProjectUsecase>(),
          gh<_i211.GetIssuesByAssigneeUsecase>(),
          gh<_i879.GetIssueByIdUsecase>(),
          gh<_i385.UpdateIssueUsecase>(),
          gh<_i177.DeleteIssueUsecase>(),
        ));
    gh.factory<_i32.ProjectCubit>(() => _i32.ProjectCubit(
          getAllProjectsUseCase: gh<_i760.GetAllProjectsUsecase>(),
          createProjectUseCase: gh<_i644.CreateProjectUseCase>(),
          removeProjectUsecase: gh<_i134.RemoveProjectUsecase>(),
          updateProjectUsecase: gh<_i723.UpdateProjectUsecase>(),
        ));
    return this;
  }
}
