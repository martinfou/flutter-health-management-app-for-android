// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicationLogModelAdapter extends TypeAdapter<MedicationLogModel> {
  @override
  final int typeId = 3;

  @override
  MedicationLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MedicationLogModel()
      ..id = fields[0] as String
      ..medicationId = fields[1] as String
      ..takenAt = fields[2] as DateTime
      ..dosage = fields[3] as String
      ..notes = fields[4] as String?
      ..createdAt = fields[5] as DateTime;
  }

  @override
  void write(BinaryWriter writer, MedicationLogModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.medicationId)
      ..writeByte(2)
      ..write(obj.takenAt)
      ..writeByte(3)
      ..write(obj.dosage)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
