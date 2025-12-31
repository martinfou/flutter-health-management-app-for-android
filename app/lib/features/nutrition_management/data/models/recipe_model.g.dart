// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecipeModelAdapter extends TypeAdapter<RecipeModel> {
  @override
  final int typeId = 6;

  @override
  RecipeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecipeModel()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..description = fields[2] as String?
      ..servings = fields[3] as int
      ..prepTime = fields[4] as int
      ..cookTime = fields[5] as int
      ..difficulty = fields[6] as String
      ..protein = fields[7] as double
      ..fats = fields[8] as double
      ..netCarbs = fields[9] as double
      ..calories = fields[10] as double
      ..ingredients = (fields[11] as List).cast<String>()
      ..instructions = (fields[12] as List).cast<String>()
      ..tags = (fields[13] as List).cast<String>()
      ..imageUrl = fields[14] as String?
      ..createdAt = fields[15] as DateTime
      ..updatedAt = fields[16] as DateTime;
  }

  @override
  void write(BinaryWriter writer, RecipeModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.servings)
      ..writeByte(4)
      ..write(obj.prepTime)
      ..writeByte(5)
      ..write(obj.cookTime)
      ..writeByte(6)
      ..write(obj.difficulty)
      ..writeByte(7)
      ..write(obj.protein)
      ..writeByte(8)
      ..write(obj.fats)
      ..writeByte(9)
      ..write(obj.netCarbs)
      ..writeByte(10)
      ..write(obj.calories)
      ..writeByte(11)
      ..write(obj.ingredients)
      ..writeByte(12)
      ..write(obj.instructions)
      ..writeByte(13)
      ..write(obj.tags)
      ..writeByte(14)
      ..write(obj.imageUrl)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
