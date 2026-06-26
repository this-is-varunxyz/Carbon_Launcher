import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;
  GetTasksUseCase(this.repository);

  Future<List<TaskEntity>> call() async {
    return await repository.getTasks();
  }
}

class AddTaskUseCase {
  final TaskRepository repository;
  AddTaskUseCase(this.repository);

  Future<void> call(TaskEntity task) async {
    await repository.addTask(task);
  }
}

class UpdateTaskUseCase {
  final TaskRepository repository;
  UpdateTaskUseCase(this.repository);

  Future<void> call(TaskEntity task) async {
    await repository.updateTask(task);
  }
}

class DeleteTaskUseCase {
  final TaskRepository repository;
  DeleteTaskUseCase(this.repository);

  Future<void> call(String id) async {
    await repository.deleteTask(id);
  }
}
