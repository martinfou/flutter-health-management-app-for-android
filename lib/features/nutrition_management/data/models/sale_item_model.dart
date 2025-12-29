import 'package:hive/hive.dart';
import 'package:health_app/features/nutrition_management/domain/entities/sale_item.dart';

part 'sale_item_model.g.dart';

/// SaleItem Hive data model
/// 
/// Hive adapter for SaleItem entity.
/// Uses typeId 9 as specified in database schema.
@HiveType(typeId: 9)
class SaleItemModel extends HiveObject {
  /// Unique identifier (UUID)
  @HiveField(0)
  late String id;

  /// Item name
  @HiveField(1)
  late String name;

  /// Category ('produce', 'meat', 'dairy', 'pantry')
  @HiveField(2)
  late String category;

  /// Store name
  @HiveField(3)
  late String store;

  /// Regular price
  @HiveField(4)
  late double regularPrice;

  /// Sale price
  @HiveField(5)
  late double salePrice;

  /// Discount percentage
  @HiveField(6)
  late double discountPercent;

  /// Unit ('lb', 'oz', 'each')
  @HiveField(7)
  late String unit;

  /// Valid from date
  @HiveField(8)
  late DateTime validFrom;

  /// Valid to date
  @HiveField(9)
  late DateTime validTo;

  /// Optional description
  @HiveField(10)
  String? description;

  /// Optional image URL
  @HiveField(11)
  String? imageUrl;

  /// Source ('api', 'manual', 'scraped')
  @HiveField(12)
  late String source;

  /// Creation timestamp
  @HiveField(13)
  late DateTime createdAt;

  /// Last update timestamp
  @HiveField(14)
  late DateTime updatedAt;

  /// Default constructor for Hive
  SaleItemModel();

  /// Convert to domain entity
  SaleItem toEntity() {
    return SaleItem(
      id: id,
      name: name,
      category: category,
      store: store,
      regularPrice: regularPrice,
      salePrice: salePrice,
      discountPercent: discountPercent,
      unit: unit,
      validFrom: validFrom,
      validTo: validTo,
      description: description,
      imageUrl: imageUrl,
      source: source,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory SaleItemModel.fromEntity(SaleItem entity) {
    final model = SaleItemModel()
      ..id = entity.id
      ..name = entity.name
      ..category = entity.category
      ..store = entity.store
      ..regularPrice = entity.regularPrice
      ..salePrice = entity.salePrice
      ..discountPercent = entity.discountPercent
      ..unit = entity.unit
      ..validFrom = entity.validFrom
      ..validTo = entity.validTo
      ..description = entity.description
      ..imageUrl = entity.imageUrl
      ..source = entity.source
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;
    return model;
  }
}

