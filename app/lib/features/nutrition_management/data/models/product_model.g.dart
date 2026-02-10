// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 15;

  @override
  ProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductModel()
      ..name = fields[0] as String
      ..barcode = fields[1] as String?
      ..brand = fields[2] as String?
      ..imageUrl = fields[3] as String?
      ..protein = fields[4] as double
      ..fats = fields[5] as double
      ..netCarbs = fields[6] as double
      ..calories = fields[7] as double
      ..ingredientsText = fields[8] as String?
      ..nutriscore = fields[9] as String?
      ..source = fields[10] as String
      ..cachedAt = fields[11] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.barcode)
      ..writeByte(2)
      ..write(obj.brand)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.protein)
      ..writeByte(5)
      ..write(obj.fats)
      ..writeByte(6)
      ..write(obj.netCarbs)
      ..writeByte(7)
      ..write(obj.calories)
      ..writeByte(8)
      ..write(obj.ingredientsText)
      ..writeByte(9)
      ..write(obj.nutriscore)
      ..writeByte(10)
      ..write(obj.source)
      ..writeByte(11)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
