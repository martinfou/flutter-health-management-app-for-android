// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseModelAdapter extends TypeAdapter<ExerciseModel> {
  @override
  final int typeId = 5;

  @override
  ExerciseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseModel()
      ..id = fields[0] as String
      ..userId = fields[1] as String
      ..name = fields[2] as String
      ..type = fields[3] as String
      ..muscleGroups = (fields[4] as List).cast<String>()
      ..equipment = (fields[5] as List).cast<String>()
      ..duration = fields[6] as int?
      ..sets = fields[7] as int?
      ..reps = fields[8] as int?
      ..weight = fields[9] as double?
      ..distance = fields[10] as double?
      ..date = fields[11] as DateTime?
      ..notes = fields[12] as String?
      ..createdAt = fields[13] as DateTime
      ..updatedAt = fields[14] as DateTime;
  }

  @override
  void write(BinaryWriter writer, ExerciseModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.muscleGroups)
      ..writeByte(5)
      ..write(obj.equipment)
      ..writeByte(6)
      ..write(obj.duration)
      ..writeByte(7)
      ..write(obj.sets)
      ..writeByte(8)
      ..write(obj.reps)
      ..writeByte(9)
      ..write(obj.weight)
      ..writeByte(10)
      ..write(obj.distance)
      ..writeByte(11)
      ..write(obj.date)
      ..writeByte(12)
      ..write(obj.notes)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
