import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

abstract class AppLocalDataSource {
  Future<List<AppInfo>> getInstalledApps({required bool withIcon});
  Future<void> launchApp(String packageName);
}

class AppLocalDataSourceImpl implements AppLocalDataSource {
  @override
  Future<List<AppInfo>> getInstalledApps({required bool withIcon}) async {
    return await InstalledApps.getInstalledApps(
      excludeSystemApps: false,
      withIcon: withIcon,
    );
  }

  @override
  Future<void> launchApp(String packageName) async {
    await InstalledApps.startApp(packageName);
  }
}