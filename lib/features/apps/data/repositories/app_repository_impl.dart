import '../../domain/entities/app_entity.dart';
import '../../domain/repositories/app_repository.dart';
import '../datasources/app_local_data_source.dart';

class AppRepositoryImpl implements AppRepository {
  final AppLocalDataSource dataSource;

  AppRepositoryImpl(this.dataSource);

  @override
  Future<List<AppEntity>> getInstalledApps() async {
    final rawApps = await dataSource.getInstalledApps();
    
 
    final apps = rawApps.map((app) => AppEntity(
      name: app.name ?? 'Unknown',
      packageName: app.packageName ?? '',
    )).toList();

 
    apps.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    
    return apps;
  }

  @override
  Future<void> launchApp(String packageName) async {
    await dataSource.launchApp(packageName);
  }
}
