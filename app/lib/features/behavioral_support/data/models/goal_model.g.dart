// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GoalModelAdapter extends TypeAdapter<GoalModel> {
  @override
  final int typeId = 14;

  @override
  GoalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GoalModel()
      ..id = fields[0] as String
      ..userId = fields[1] as String
      ..type = fields[2] as String
      ..description = fields[3] as String
      ..target = fields[4] as String?
      ..targetValue = fields[5] as double?
      ..currentValue = fields[6] as double
      ..deadline = fields[7] as DateTime?
      ..linkedMetric = fields[8] as String?
      ..status = fields[9] as String
      ..completedAt = fields[10] as DateTime?
      ..createdAt = fields[11] as DateTime
      ..updatedAt = fields[12] as DateTime;
  }

  @override
  void write(BinaryWriter writer, GoalModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.target)
      ..writeByte(5)
      ..write(obj.targetValue)
      ..writeByte(6)
      ..write(obj.currentValue)
      ..writeByte(7)
      ..write(obj.deadline)
      ..writeByte(8)
      ..write(obj.linkedMetric)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.completedAt)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoalModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
