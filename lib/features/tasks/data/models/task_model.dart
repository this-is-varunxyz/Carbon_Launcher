import 'package:hive/hive.dart';
import '../../domain/entities/task_entity.dart';

part 'task_model.g.dart'; 

@HiveType(typeId: 0)
enum TaskTypeModel {
  @HiveField(0) normal,
  @HiveField(1) deadline,
}

@HiveType(typeId: 1)
enum TaskPriorityModel {
  @HiveField(0) none,
  @HiveField(1) low,
  @HiveField(2) medium,
  @HiveField(3) high,
}

@HiveType(typeId: 2)
class TaskModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late TaskTypeModel type;

  @HiveField(3)
  late bool isCompleted;

  @HiveField(4)
  late TaskPriorityModel priority;

  @HiveField(5)
  DateTime? deadline;

  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      title: title,
      type: TaskType.values[type.index],
      isCompleted: isCompleted,
      priority: TaskPriority.values[priority.index],
      deadline: deadline,
    );
  }

  static TaskModel fromEntity(TaskEntity entity) {
    return TaskModel()
      ..id = entity.id
      ..title = entity.title
      ..type = TaskTypeModel.values[entity.type.index]
      ..isCompleted = entity.isCompleted
      ..priority = TaskPriorityModel.values[entity.priority.index]
      ..deadline = entity.deadline;
  }
}