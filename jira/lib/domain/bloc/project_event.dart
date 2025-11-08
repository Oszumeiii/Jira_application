abstract class ProjectEvent {}

class LoadProjects extends ProjectEvent {}

class CreateProject extends ProjectEvent {
  final String name;
  CreateProject(this.name);
}
