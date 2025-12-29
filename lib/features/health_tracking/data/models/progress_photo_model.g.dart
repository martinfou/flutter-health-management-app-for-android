// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_photo_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgressPhotoModelAdapter extends TypeAdapter<ProgressPhotoModel> {
  @override
  final int typeId = 10;

  @override
  ProgressPhotoModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressPhotoModel()
      ..id = fields[0] as String
      ..healthMetricId = fields[1] as String
      ..photoType = fields[2] as String
      ..imagePath = fields[3] as String
      ..date = fields[4] as DateTime
      ..createdAt = fields[5] as DateTime;
  }

  @override
  void write(BinaryWriter writer, ProgressPhotoModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.healthMetricId)
      ..writeByte(2)
      ..write(obj.photoType)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressPhotoModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
