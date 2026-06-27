import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/app_usecases.dart';
import 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  final GetInstalledAppsUseCase getInstalledAppsUseCase;
  final LaunchAppUseCase launchAppUseCase;

  AppCubit({
    required this.getInstalledAppsUseCase,
    required this.launchAppUseCase,
  }) : super(AppInitial());

  Future<void> loadApps({bool forceRefresh = false}) async {
    if (!forceRefresh && state is AppLoaded) return;

    emit(AppLoading());
    try {
      final apps = await getInstalledAppsUseCase();
      emit(AppLoaded(apps));
    } catch (e) {
      emit(AppError('Failed to load apps: $e'));
    }
  }

  Future<void> launchApp(String packageName) async {
    try {
      await launchAppUseCase(packageName);
    } catch (e) {
      print('Could not launch app: $e');
    }
  }
}
