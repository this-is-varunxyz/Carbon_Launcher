import '../entities/app_entity.dart';

abstract class AppRepository {
  Future<List<AppEntity>> getInstalledApps();
  Future<void> launchApp(String packageName);
}
