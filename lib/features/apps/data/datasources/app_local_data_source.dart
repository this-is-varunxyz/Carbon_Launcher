import 'package:installed_apps/installed_apps.dart';
import 'package:installed_apps/app_info.dart';

abstract class AppLocalDataSource {
  Future<List<AppInfo>> getInstalledApps();
  Future<void> launchApp(String packageName);
}

class AppLocalDataSourceImpl implements AppLocalDataSource {
  @override
  Future<List<AppInfo>> getInstalledApps() async {
 
    return await InstalledApps.getInstalledApps(
      excludeSystemApps: true,
      withIcon: false, 
    );
  }

  @override
  Future<void> launchApp(String packageName) async {
    await InstalledApps.startApp(packageName);
  }
}
