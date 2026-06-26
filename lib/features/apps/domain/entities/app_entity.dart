import 'dart:typed_data';

class AppEntity {
  final String name;
  final String packageName;
  final Uint8List? icon; 

  AppEntity({
    required this.name,
    required this.packageName,
    this.icon,
  });
}