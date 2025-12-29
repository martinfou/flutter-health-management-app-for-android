// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesModelAdapter extends TypeAdapter<UserPreferencesModel> {
  @override
  final int typeId = 12;

  @override
  UserPreferencesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferencesModel()
      ..dietaryApproach = fields[0] as String
      ..preferredMealTimes = (fields[1] as List).cast<String>()
      ..allergies = (fields[2] as List).cast<String>()
      ..dislikes = (fields[3] as List).cast<String>()
      ..fitnessGoals = (fields[4] as List).cast<String>()
      ..notificationPreferences = (fields[5] as Map).cast<String, bool>()
      ..units = fields[6] as String
      ..theme = fields[7] as String;
  }

  @override
  void write(BinaryWriter writer, UserPreferencesModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.dietaryApproach)
      ..writeByte(1)
      ..write(obj.preferredMealTimes)
      ..writeByte(2)
      ..write(obj.allergies)
      ..writeByte(3)
      ..write(obj.dislikes)
      ..writeByte(4)
      ..write(obj.fitnessGoals)
      ..writeByte(5)
      ..write(obj.notificationPreferences)
      ..writeByte(6)
      ..write(obj.units)
      ..writeByte(7)
      ..write(obj.theme);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
