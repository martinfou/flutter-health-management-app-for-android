/// Domain entity representing a food product from Open Food Facts.
///
/// Used for food search autocomplete and barcode lookup results.
/// Maps nutritional data per 100g; serving size conversion done at display time.
class Product {
  /// Product display name
  final String name;

  /// Product barcode (EAN, UPC, etc.)
  final String? barcode;

  /// Brand name
  final String? brand;

  /// Product image URL (front, small)
  final String? imageUrl;

  /// Protein per 100g (grams)
  final double protein;

  /// Fats per 100g (grams)
  final double fats;

  /// Net carbs per 100g (carbohydrates - fiber)
  final double netCarbs;

  /// Calories per 100g (kcal)
  final double calories;

  /// Ingredients list text
  final String? ingredientsText;

  /// Nutri-Score grade (a, b, c, d, e) if available
  final String? nutriscore;

  /// Data source: 'api' = Open Food Facts API, 'local' = cached/common foods
  final String source;

  /// Timestamp when product was cached (for cache eviction)
  final DateTime? cachedAt;

  const Product({
    required this.name,
    this.barcode,
    this.brand,
    this.imageUrl,
    required this.protein,
    required this.fats,
    required this.netCarbs,
    required this.calories,
    this.ingredientsText,
    this.nutriscore,
    this.source = 'api',
    this.cachedAt,
  });

  /// Ingredients as list (split by comma)
  List<String> get ingredients {
    if (ingredientsText == null || ingredientsText!.trim().isEmpty) {
      return [name];
    }
    return ingredientsText!
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Convert to FoodItem format for meal logging (per 100g serving).
  /// Use [servingSizeGrams] to scale for different serving sizes.
  Map<String, dynamic> toFoodItemData({double servingSizeGrams = 100}) {
    final factor = servingSizeGrams / 100;
    return {
      'name': name,
      'protein': protein * factor,
      'fats': fats * factor,
      'netCarbs': netCarbs * factor,
      'calories': calories * factor,
      'ingredients': ingredients,
    };
  }
}
