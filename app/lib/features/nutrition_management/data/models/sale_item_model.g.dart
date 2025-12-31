// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleItemModelAdapter extends TypeAdapter<SaleItemModel> {
  @override
  final int typeId = 9;

  @override
  SaleItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleItemModel()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..category = fields[2] as String
      ..store = fields[3] as String
      ..regularPrice = fields[4] as double
      ..salePrice = fields[5] as double
      ..discountPercent = fields[6] as double
      ..unit = fields[7] as String
      ..validFrom = fields[8] as DateTime
      ..validTo = fields[9] as DateTime
      ..description = fields[10] as String?
      ..imageUrl = fields[11] as String?
      ..source = fields[12] as String
      ..createdAt = fields[13] as DateTime
      ..updatedAt = fields[14] as DateTime;
  }

  @override
  void write(BinaryWriter writer, SaleItemModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.store)
      ..writeByte(4)
      ..write(obj.regularPrice)
      ..writeByte(5)
      ..write(obj.salePrice)
      ..writeByte(6)
      ..write(obj.discountPercent)
      ..writeByte(7)
      ..write(obj.unit)
      ..writeByte(8)
      ..write(obj.validFrom)
      ..writeByte(9)
      ..write(obj.validTo)
      ..writeByte(10)
      ..write(obj.description)
      ..writeByte(11)
      ..write(obj.imageUrl)
      ..writeByte(12)
      ..write(obj.source)
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
      other is SaleItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
