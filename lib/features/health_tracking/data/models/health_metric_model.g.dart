// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_metric_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HealthMetricModelAdapter extends TypeAdapter<HealthMetricModel> {
  @override
  final int typeId = 1;

  @override
  HealthMetricModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HealthMetricModel()
      ..id = fields[0] as String
      ..userId = fields[1] as String
      ..date = fields[2] as DateTime
      ..weight = fields[3] as double?
      ..sleepQuality = fields[4] as int?
      ..energyLevel = fields[5] as int?
      ..restingHeartRate = fields[6] as int?
      ..bodyMeasurements = (fields[7] as Map?)?.cast<String, double>()
      ..notes = fields[8] as String?
      ..createdAt = fields[9] as DateTime
      ..updatedAt = fields[10] as DateTime;
  }

  @override
  void write(BinaryWriter writer, HealthMetricModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.weight)
      ..writeByte(4)
      ..write(obj.sleepQuality)
      ..writeByte(5)
      ..write(obj.energyLevel)
      ..writeByte(6)
      ..write(obj.restingHeartRate)
      ..writeByte(7)
      ..write(obj.bodyMeasurements)
      ..writeByte(8)
      ..write(obj.notes)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthMetricModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
