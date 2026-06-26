import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/database/hive_setup.dart';
import 'package:flutter/services.dart';
import 'features/tasks/data/datasources/task_local_data_source.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/domain/usecases/task_usecases.dart';
import 'features/tasks/presentation/bloc/task_cubit.dart';

import 'features/tasks/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await HiveSetup.init();

  final taskLocalDataSource = TaskLocalDataSourceImpl();

  final taskRepository = TaskRepositoryImpl(taskLocalDataSource);

  final getTasksUseCase = GetTasksUseCase(taskRepository);
  final addTaskUseCase = AddTaskUseCase(taskRepository);
  final updateTaskUseCase = UpdateTaskUseCase(taskRepository);
  final deleteTaskUseCase = DeleteTaskUseCase(taskRepository);

  runApp(
    CarbonLauncherApp(
      getTasksUseCase: getTasksUseCase,
      addTaskUseCase: addTaskUseCase,
      updateTaskUseCase: updateTaskUseCase,
      deleteTaskUseCase: deleteTaskUseCase,
    ),
  );
}

class CarbonLauncherApp extends StatelessWidget {
  final GetTasksUseCase getTasksUseCase;
  final AddTaskUseCase addTaskUseCase;
  final UpdateTaskUseCase updateTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;

  const CarbonLauncherApp({
    super.key,
    required this.getTasksUseCase,
    required this.addTaskUseCase,
    required this.updateTaskUseCase,
    required this.deleteTaskUseCase,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskCubit>(
          create: (context) => TaskCubit(
            getTasksUseCase: getTasksUseCase,
            addTaskUseCase: addTaskUseCase,
            updateTaskUseCase: updateTaskUseCase,
            deleteTaskUseCase: deleteTaskUseCase,
          )..loadTasks(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Carbon Launcher',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF0F0F0),
        ),
        home: const HomePage(),
      ),
    );
  }
}
