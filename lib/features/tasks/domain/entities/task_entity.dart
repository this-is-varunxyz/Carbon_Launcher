enum TaskType { normal, deadline }
enum TaskPriority { none, low, medium, high }

class TaskEntity {
  final String id;
  final String title;
  final TaskType type;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime? deadline;

  TaskEntity({
    required this.id,
    required this.title,
    required this.type,
    this.isCompleted = false,
    this.priority = TaskPriority.none,
    this.deadline,
  });
}