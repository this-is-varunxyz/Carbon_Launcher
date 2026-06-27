import 'dart:typed_data';
import '../entities/app_entity.dart';

abstract class AppRepository {
  Future<List<AppEntity>> getInstalledApps({required bool withIcon});
  Future<void> launchApp(String packageName);
  Future<Uint8List?> getAppIcon(String packageName);
}
