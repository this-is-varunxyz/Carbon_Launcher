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

  Future<void> loadApps() async {
    emit(AppLoading());
    try {
      final fastApps = await getInstalledAppsUseCase(withIcon: false);
      emit(AppLoaded(apps: fastApps, isIconsLoaded: false));

      final fullApps = await getInstalledAppsUseCase(withIcon: true);
      emit(AppLoaded(apps: fullApps, isIconsLoaded: true));
    } catch (e) {
      emit(AppError('Failed to load apps: $e'));
    }
  }

  Future<void> launchApp(String packageName) async {
    try { await launchAppUseCase(packageName); } catch (_) {}
  }
}