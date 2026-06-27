import 'dart:typed_data';

class AppEntity {
  final String name;
  final String packageName;
  final Uint8List? icon; 
  final String nameLower;

  AppEntity({
    required this.name,
    required this.packageName,
    required this.nameLower,
    this.icon,
  });
}