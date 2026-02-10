import 'package:fpdart/fpdart.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/core/providers/database_provider.dart';
import 'package:health_app/features/nutrition_management/data/models/product_model.dart';
import 'package:health_app/features/nutrition_management/domain/entities/product.dart';

/// Local data source for Open Food Facts product cache.
///
/// Stores searched/scanned products for offline use and faster autocomplete.
class OpenFoodFactsLocalDataSource {
  OpenFoodFactsLocalDataSource();

  Box<ProductModel> get _box {
    if (!Hive.isBoxOpen(HiveBoxNames.products)) {
      throw DatabaseFailure('Products box is not open');
    }
    return Hive.box<ProductModel>(HiveBoxNames.products);
  }

  /// Max products to scan in one search (avoids blocking UI on large boxes).
  static const int _maxScan = 300;

  /// Search local products by name (case-insensitive contains).
  /// Limits scan to [_maxScan] items so the main thread is not blocked.
  Future<Result<List<Product>>> searchLocalProducts(
    String query, {
    int limit = 10,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return const Right([]);
      }

      final lowerQuery = query.trim().toLowerCase();
      final results = _box.values
          .take(_maxScan)
          .where((m) => m.name.toLowerCase().contains(lowerQuery))
          .take(limit)
          .map((m) => m.toEntity())
          .toList();

      return Right(results);
    } catch (e) {
      return Left(DatabaseFailure('Failed to search local products: $e'));
    }
  }

  /// Get product by barcode from local cache.
  Future<Result<Product?>> getLocalProductByBarcode(String barcode) async {
    try {
      final key = _barcodeKey(barcode);
      final model = _box.get(key);
      return Right(model?.toEntity());
    } catch (e) {
      return Left(DatabaseFailure('Failed to get local product: $e'));
    }
  }

  /// Save products to local cache (for API results and barcode lookups).
  Future<Result<void>> saveProducts(List<Product> products) async {
    try {
      final now = DateTime.now();
      for (final p in products) {
        final key = _productKey(p);
        final model = ProductModel.fromEntity(
          Product(
            name: p.name,
            barcode: p.barcode,
            brand: p.brand,
            imageUrl: p.imageUrl,
            protein: p.protein,
            fats: p.fats,
            netCarbs: p.netCarbs,
            calories: p.calories,
            ingredientsText: p.ingredientsText,
            nutriscore: p.nutriscore,
            source: p.source,
            cachedAt: now,
          ),
        );
        await _box.put(key, model);
      }
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure('Failed to save products: $e'));
    }
  }

  /// Save single product.
  Future<Result<void>> saveProduct(Product product) async {
    return saveProducts([product]);
  }

  String _productKey(Product p) => p.barcode ?? p.name;
  String _barcodeKey(String barcode) => barcode;
}
