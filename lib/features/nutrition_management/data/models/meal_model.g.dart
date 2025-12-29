// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealModelAdapter extends TypeAdapter<MealModel> {
  @override
  final int typeId = 4;

  @override
  MealModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealModel()
      ..id = fields[0] as String
      ..userId = fields[1] as String
      ..date = fields[2] as DateTime
      ..mealType = fields[3] as String
      ..name = fields[4] as String
      ..protein = fields[5] as double
      ..fats = fields[6] as double
      ..netCarbs = fields[7] as double
      ..calories = fields[8] as double
      ..ingredients = (fields[9] as List).cast<String>()
      ..recipeId = fields[10] as String?
      ..createdAt = fields[11] as DateTime;
  }

  @override
  void write(BinaryWriter writer, MealModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.mealType)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.protein)
      ..writeByte(6)
      ..write(obj.fats)
      ..writeByte(7)
      ..write(obj.netCarbs)
      ..writeByte(8)
      ..write(obj.calories)
      ..writeByte(9)
      ..write(obj.ingredients)
      ..writeByte(10)
      ..write(obj.recipeId)
      ..writeByte(11)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
