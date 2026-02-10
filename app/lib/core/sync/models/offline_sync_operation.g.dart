// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_sync_operation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OfflineSyncOperationAdapter extends TypeAdapter<OfflineSyncOperation> {
  @override
  final int typeId = 11;

  @override
  OfflineSyncOperation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OfflineSyncOperation()
      ..id = fields[0] as String
      ..dataTypeStr = fields[1] as String
      ..operation = fields[2] as String
      ..data = (fields[3] as Map).cast<String, dynamic>()
      ..timestamp = fields[4] as DateTime
      ..retryCount = fields[5] as int;
  }

  @override
  void write(BinaryWriter writer, OfflineSyncOperation obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dataTypeStr)
      ..writeByte(2)
      ..write(obj.operation)
      ..writeByte(3)
      ..write(obj.data)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.retryCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfflineSyncOperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
