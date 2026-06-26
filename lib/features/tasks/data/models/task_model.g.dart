// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelAdapter extends TypeAdapter<TaskModel> {
  @override
  final int typeId = 2;

  @override
  TaskModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModel()
      ..id = fields[0] as String
      ..title = fields[1] as String
      ..type = fields[2] as TaskTypeModel
      ..isCompleted = fields[3] as bool
      ..priority = fields[4] as TaskPriorityModel
      ..deadline = fields[5] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, TaskModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.isCompleted)
      ..writeByte(4)
      ..write(obj.priority)
      ..writeByte(5)
      ..write(obj.deadline);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskTypeModelAdapter extends TypeAdapter<TaskTypeModel> {
  @override
  final int typeId = 0;

  @override
  TaskTypeModel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskTypeModel.normal;
      case 1:
        return TaskTypeModel.deadline;
      default:
        return TaskTypeModel.normal;
    }
  }

  @override
  void write(BinaryWriter writer, TaskTypeModel obj) {
    switch (obj) {
      case TaskTypeModel.normal:
        writer.writeByte(0);
        break;
      case TaskTypeModel.deadline:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskTypeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TaskPriorityModelAdapter extends TypeAdapter<TaskPriorityModel> {
  @override
  final int typeId = 1;

  @override
  TaskPriorityModel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TaskPriorityModel.none;
      case 1:
        return TaskPriorityModel.low;
      case 2:
        return TaskPriorityModel.medium;
      case 3:
        return TaskPriorityModel.high;
      default:
        return TaskPriorityModel.none;
    }
  }

  @override
  void write(BinaryWriter writer, TaskPriorityModel obj) {
    switch (obj) {
      case TaskPriorityModel.none:
        writer.writeByte(0);
        break;
      case TaskPriorityModel.low:
        writer.writeByte(1);
        break;
      case TaskPriorityModel.medium:
        writer.writeByte(2);
        break;
      case TaskPriorityModel.high:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskPriorityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
