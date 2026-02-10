import 'package:hive/hive.dart';
import 'package:health_app/features/nutrition_management/domain/entities/product.dart';

part 'product_model.g.dart';

/// Hive model for cached Open Food Facts products.
///
/// Used for local cache and common foods. TypeId 15.
@HiveType(typeId: 15)
class ProductModel extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  String? barcode;

  @HiveField(2)
  String? brand;

  @HiveField(3)
  String? imageUrl;

  @HiveField(4)
  late double protein;

  @HiveField(5)
  late double fats;

  @HiveField(6)
  late double netCarbs;

  @HiveField(7)
  late double calories;

  @HiveField(8)
  String? ingredientsText;

  @HiveField(9)
  String? nutriscore;

  @HiveField(10)
  late String source;

  @HiveField(11)
  DateTime? cachedAt;

  ProductModel();

  Product toEntity() => Product(
        name: name,
        barcode: barcode,
        brand: brand,
        imageUrl: imageUrl,
        protein: protein,
        fats: fats,
        netCarbs: netCarbs,
        calories: calories,
        ingredientsText: ingredientsText,
        nutriscore: nutriscore,
        source: source,
        cachedAt: cachedAt,
      );

  factory ProductModel.fromEntity(Product entity) {
    final model = ProductModel()
      ..name = entity.name
      ..barcode = entity.barcode
      ..brand = entity.brand
      ..imageUrl = entity.imageUrl
      ..protein = entity.protein
      ..fats = entity.fats
      ..netCarbs = entity.netCarbs
      ..calories = entity.calories
      ..ingredientsText = entity.ingredientsText
      ..nutriscore = entity.nutriscore
      ..source = entity.source
      ..cachedAt = entity.cachedAt;
    return model;
  }
}
