import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/task_usecases.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final GetTasksUseCase getTasksUseCase;
  final AddTaskUseCase addTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  TaskCubit({
    required this.getTasksUseCase,
    required this.addTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
  }) : super(TaskInitial());

  Future<void> loadTasks() async {
    emit(TaskLoading());
    try {
      final tasks = await getTasksUseCase();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError('Failed to load tasks: $e'));
    }
  }

  Future<void> addTask(TaskEntity task) async {
    try {
      await addTaskUseCase(task);
      await loadTasks(); 
    } catch (e) {
      emit(TaskError('Failed to add task: $e'));
    }
  }

  Future<void> toggleTaskCompletion(TaskEntity task) async {
    try {
      final updatedTask = TaskEntity(
        id: task.id,
        title: task.title,
        type: task.type,
        isCompleted: !task.isCompleted, 
        priority: task.priority,
        deadline: task.deadline,
      );
      await updateTaskUseCase(updatedTask);
      await loadTasks(); 
    } catch (e) {
      emit(TaskError('Failed to update task: $e'));
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await deleteTaskUseCase(id);
      await loadTasks(); 
    } catch (e) {
      emit(TaskError('Failed to delete task: $e'));
    }
  }
}
