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
import 'package:jira/features/dash_board/projects/presentation/cubit/project_cubit.dart'
    as _i32;

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
    gh.factory<_i355.ProjectRemoteDataSource>(
        () => _i355.ProjectRemoteDataSourceImpl());
    gh.factory<_i688.ProjectRepository>(
        () => _i77.ProjectRepositoryImpl(gh<_i355.ProjectRemoteDataSource>()));
    gh.factory<_i644.CreateProjectUseCase>(
        () => _i644.CreateProjectUseCase(gh<_i688.ProjectRepository>()));
    gh.factory<_i760.GetAllProjectsUsecase>(
        () => _i760.GetAllProjectsUsecase(gh<_i688.ProjectRepository>()));
    gh.factory<_i32.ProjectCubit>(() => _i32.ProjectCubit(
          getAllProjectsUseCase: gh<_i760.GetAllProjectsUsecase>(),
          createProjectUseCase: gh<_i644.CreateProjectUseCase>(),
        ));
    return this;
  }
}
