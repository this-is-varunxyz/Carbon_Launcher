import '../entities/app_entity.dart';
import '../repositories/app_repository.dart';

class GetInstalledAppsUseCase {
  final AppRepository repository;
  GetInstalledAppsUseCase(this.repository);

  Future<List<AppEntity>> call({required bool withIcon}) async {
    return await repository.getInstalledApps(withIcon: withIcon);
  }
}

class LaunchAppUseCase {
  final AppRepository repository;
  LaunchAppUseCase(this.repository);

  Future<void> call(String packageName) async {
    await repository.launchApp(packageName);
  }
}
