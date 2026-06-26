import 'package:hive_flutter/hive_flutter.dart';
import '../../features/tasks/data/models/task_model.dart';

class HiveSetup {
  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(TaskTypeModelAdapter());
    Hive.registerAdapter(TaskPriorityModelAdapter());
    Hive.registerAdapter(TaskModelAdapter());

    await Hive.openBox<TaskModel>('tasksBox');
  }
}