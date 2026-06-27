import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';

import 'core/database/hive_setup.dart';

import 'features/tasks/data/datasources/task_local_data_source.dart';
import 'features/tasks/data/repositories/task_repository_impl.dart';
import 'features/tasks/domain/usecases/task_usecases.dart';
import 'features/tasks/presentation/bloc/task_cubit.dart';

import 'features/apps/data/datasources/app_local_data_source.dart';
import 'features/apps/data/repositories/app_repository_impl.dart';
import 'features/apps/domain/usecases/app_usecases.dart';
import 'features/apps/presentation/bloc/app_cubit.dart';

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

  final appLocalDataSource = AppLocalDataSourceImpl();
  final appRepository = AppRepositoryImpl(appLocalDataSource);
  final getInstalledAppsUseCase = GetInstalledAppsUseCase(appRepository);
  final launchAppUseCase = LaunchAppUseCase(appRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<TaskCubit>(
          create: (_) => TaskCubit(
            getTasksUseCase: getTasksUseCase,
            addTaskUseCase: addTaskUseCase,
            updateTaskUseCase: updateTaskUseCase,
            deleteTaskUseCase: deleteTaskUseCase,
          )..loadTasks(),
        ),
        
        BlocProvider<AppCubit>(
          create: (_) => AppCubit(
            getInstalledAppsUseCase: getInstalledAppsUseCase,
            launchAppUseCase: launchAppUseCase,
          ),
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
    ),
  );
}