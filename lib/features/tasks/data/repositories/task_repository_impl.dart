import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_data_source.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl(this.localDataSource);

  @override
  Future<List<TaskEntity>> getTasks() async {
    final taskModels = await localDataSource.getTasks();
    return taskModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addTask(TaskEntity task) async {
    final taskModel = TaskModel.fromEntity(task);
    await localDataSource.addTask(taskModel);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    final taskModel = TaskModel.fromEntity(task);
    await localDataSource.updateTask(taskModel);
  }

  @override
  Future<void> deleteTask(String id) async {
    await localDataSource.deleteTask(id);
  }
}