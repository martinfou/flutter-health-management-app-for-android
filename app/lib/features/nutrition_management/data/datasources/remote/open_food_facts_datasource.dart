import 'package:fpdart/fpdart.dart';
import 'package:health_app/core/errors/failures.dart';
import 'package:health_app/features/nutrition_management/domain/entities/product.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as off;

/// Remote data source for Open Food Facts API.
///
/// Fetches product data from Open Food Facts via official SDK.
class OpenFoodFactsRemoteDataSource {
  OpenFoodFactsRemoteDataSource();

  /// Get product by barcode.
  Future<Result<Product>> getProductByBarcode(String barcode) async {
    try {
      final config = off.ProductQueryConfiguration(
        barcode,
        version: off.ProductQueryVersion.v3,
        language: off.OpenFoodFactsLanguage.ENGLISH,
        country: off.OpenFoodFactsCountry.USA,
      );

      final result = await off.OpenFoodAPIClient.getProductV3(
        config,
        user: null,
      );

      if (result.product == null) {
        return Left(NotFoundFailure('Product'));
      }

      return Right(_mapSdkProductToEntity(result.product!));
    } catch (e) {
      return Left(NetworkFailure('Failed to fetch product: $e'));
    }
  }

  /// Search products by name.
  Future<Result<List<Product>>> searchProducts(
    String query, {
    int pageSize = 20,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return const Right([]);
      }

      final config = off.ProductSearchQueryConfiguration(
        parametersList: [
          off.SearchTerms(terms: [query.trim()]),
          off.PageSize(size: pageSize),
        ],
        version: off.ProductQueryVersion.v3,
        language: off.OpenFoodFactsLanguage.ENGLISH,
        country: off.OpenFoodFactsCountry.USA,
        fields: [
          off.ProductField.BARCODE,
          off.ProductField.NAME,
          off.ProductField.BRANDS,
          off.ProductField.IMAGE_FRONT_SMALL_URL,
          off.ProductField.NUTRIMENTS,
          off.ProductField.INGREDIENTS_TEXT,
          off.ProductField.NUTRISCORE,
        ],
      );

      final result = await off.OpenFoodAPIClient.searchProducts(
        null,
        config,
      );

      final products = result.products ?? [];
      return Right(products.map(_mapSdkProductToEntity).toList());
    } catch (e) {
      return Left(NetworkFailure('Failed to search products: $e'));
    }
  }

  Product _mapSdkProductToEntity(off.Product sdk) {
    final nutriments = sdk.nutriments;
    double protein = 0.0, fats = 0.0, carbs = 0.0, fiber = 0.0, calories = 0.0;

    if (nutriments != null) {
      protein = nutriments.getValue(off.Nutrient.proteins, off.PerSize.oneHundredGrams) ?? 0.0;
      fats = nutriments.getValue(off.Nutrient.fat, off.PerSize.oneHundredGrams) ?? 0.0;
      carbs = nutriments.getValue(off.Nutrient.carbohydrates, off.PerSize.oneHundredGrams) ?? 0.0;
      fiber = nutriments.getValue(off.Nutrient.fiber, off.PerSize.oneHundredGrams) ?? 0.0;
      final kJ = nutriments.getComputedKJ(off.PerSize.oneHundredGrams);
      calories = nutriments.getValue(off.Nutrient.energyKCal, off.PerSize.oneHundredGrams) ??
          (kJ != null ? off.NutrimentsHelper.fromKJtoKCal(kJ) : 0.0);
    }

    final netCarbs = carbs - fiber;
    final effectiveNetCarbs = netCarbs > 0 ? netCarbs : carbs;

    return Product(
      name: sdk.productName ?? 'Unknown',
      barcode: sdk.barcode,
      brand: sdk.brands,
      imageUrl: sdk.imageFrontSmallUrl ?? sdk.imageFrontUrl,
      protein: protein,
      fats: fats,
      netCarbs: effectiveNetCarbs,
      calories: calories,
      ingredientsText: sdk.ingredientsText,
      nutriscore: sdk.nutriscore?.toLowerCase(),
      source: 'api',
    );
  }
}
