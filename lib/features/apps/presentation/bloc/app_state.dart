import 'package:equatable/equatable.dart';
import '../../domain/entities/app_entity.dart';

abstract class AppState extends Equatable {
  const AppState();
  @override
  List<Object> get props => [];
}

class AppInitial extends AppState {}
class AppLoading extends AppState {}

class AppLoaded extends AppState {
  final List<AppEntity> apps;
  final bool isIconsLoaded; 

  const AppLoaded({required this.apps, this.isIconsLoaded = false});
  @override
  List<Object> get props => [apps, isIconsLoaded];
}

class AppError extends AppState {
  final String message;
  const AppError(this.message);
  @override
  List<Object> get props => [message];
}
