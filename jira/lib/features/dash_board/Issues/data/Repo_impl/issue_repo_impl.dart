import 'package:injectable/injectable.dart';
import 'package:jira/features/dash_board/Issues/data/data_source/issue_remote_data.dart';
import 'package:jira/features/dash_board/Issues/data/model/issue_model.dart';
import 'package:jira/features/dash_board/Issues/domain/Entity/issue_entity.dart';
import 'package:jira/features/dash_board/Issues/domain/Repositories/issue_repository.dart';

@Injectable(as: IssueRepository)
class IssueRepoImpl extends IssueRepository{
  final IssueRemoteDataSource remoteDataSource;
  IssueRepoImpl(this.remoteDataSource);


  @override
  Future<IssueEntity> createIssue(IssueEntity issue) {
    return remoteDataSource.createIssue(IssueModel.fromEntity(issue))
        .then((model) => model.toEntity());
  }

  @override
  Future<IssueEntity> getIssueById(String issueId) {
    // TODO: implement getIssueById
    throw UnimplementedError();
  }

  @override
  Future<List<IssueEntity>> getIssuesByAssignee(String assigneeId) {
    // TODO: implement getIssuesByAssignee
    throw UnimplementedError();
  }

@override
Future<List<IssueEntity>> getIssuesByProject(String projectId) async {
  List<IssueModel> models = await remoteDataSource.getIssuesByProject(projectId);
  List<IssueEntity> entities = models.map((model) => model.toEntity()).toList();
  return entities;
}

}