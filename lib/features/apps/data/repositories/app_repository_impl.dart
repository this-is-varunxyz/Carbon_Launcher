import 'dart:typed_data';

import '../../domain/entities/app_entity.dart';
import '../../domain/repositories/app_repository.dart';
import '../datasources/app_local_data_source.dart';

class AppRepositoryImpl implements AppRepository {
  final AppLocalDataSource dataSource;
  AppRepositoryImpl(this.dataSource);

  @override
  Future<List<AppEntity>> getInstalledApps({required bool withIcon}) async {
    final rawApps = await dataSource.getInstalledApps(withIcon: withIcon);
    
    final apps = rawApps.map((app) {
      final safeName = app.name ?? 'Unknown';
      return AppEntity(
        name: safeName,
        nameLower: safeName.toLowerCase(), 
        packageName: app.packageName ?? '',
        icon: app.icon, 
      );
    }).toList();

    apps.sort((a, b) => a.nameLower.compareTo(b.nameLower));
    return apps;
  }

  @override
  Future<void> launchApp(String packageName) async {
    await dataSource.launchApp(packageName);
  }

  @override
  Future<Uint8List?> getAppIcon(String packageName) {
    throw UnimplementedError();
  }
}