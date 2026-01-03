// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileModelAdapter extends TypeAdapter<UserProfileModel> {
  @override
  final int typeId = 0;

  @override
  UserProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfileModel()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..email = fields[2] as String
      ..dateOfBirth = fields[3] as DateTime
      ..gender = fields[4] as String
      ..height = fields[5] as double
      ..targetWeight = fields[6] as double
      ..weight = fields[7] as double
      ..fitnessGoals = (fields[8] as List).cast<String>()
      ..dietaryApproach = fields[9] as String
      ..dislikes = (fields[10] as List).cast<String>()
      ..allergies = (fields[11] as List).cast<String>()
      ..healthConditions = (fields[12] as List).cast<String>()
      ..syncEnabled = fields[13] as bool
      ..createdAt = fields[14] as DateTime
      ..updatedAt = fields[15] as DateTime;
  }

  @override
  void write(BinaryWriter writer, UserProfileModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.dateOfBirth)
      ..writeByte(4)
      ..write(obj.gender)
      ..writeByte(5)
      ..write(obj.height)
      ..writeByte(6)
      ..write(obj.targetWeight)
      ..writeByte(7)
      ..write(obj.weight)
      ..writeByte(8)
      ..write(obj.fitnessGoals)
      ..writeByte(9)
      ..write(obj.dietaryApproach)
      ..writeByte(10)
      ..write(obj.dislikes)
      ..writeByte(11)
      ..write(obj.allergies)
      ..writeByte(12)
      ..write(obj.healthConditions)
      ..writeByte(13)
      ..write(obj.syncEnabled)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
