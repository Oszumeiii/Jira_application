import 'package:jira/features/dash_board/Issues/domain/Entity/issue_entity.dart';

abstract class IssueRepository {
  Future<List<IssueEntity>> getIssuesByProject(String projectId);
  Future<IssueEntity> getIssueById(String issueId);
  //get User issue
  Future<List<IssueEntity>> getIssuesByAssignee(String assigneeId);
  Future<IssueEntity> createIssue(IssueEntity issue);
  Future<IssueEntity> updateIssue(IssueEntity issue);
  Future<bool> deleteIssue (String idIssue);
}
