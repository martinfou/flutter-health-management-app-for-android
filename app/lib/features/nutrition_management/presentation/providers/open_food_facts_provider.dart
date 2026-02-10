import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health_app/features/nutrition_management/data/datasources/local/open_food_facts_local_datasource.dart';
import 'package:health_app/features/nutrition_management/data/datasources/remote/open_food_facts_datasource.dart';
import 'package:health_app/features/nutrition_management/domain/entities/product.dart';

/// Provider for Open Food Facts remote data source.
final openFoodFactsRemoteDataSourceProvider = Provider<OpenFoodFactsRemoteDataSource>((ref) {
  return OpenFoodFactsRemoteDataSource();
});

/// Provider for Open Food Facts local data source.
final openFoodFactsLocalDataSourceProvider = Provider<OpenFoodFactsLocalDataSource>((ref) {
  return OpenFoodFactsLocalDataSource();
});

/// Search food products with dual-mode: local first, then API.
/// Debounces input and merges local + API results.
final foodSearchProvider = FutureProvider.family<List<Product>, String>((ref, query) async {
  if (query.trim().isEmpty) {
    return [];
  }

  // Yield so the loading state paints before we do work (avoids UI freeze).
  await Future.delayed(Duration.zero);

  final local = ref.read(openFoodFactsLocalDataSourceProvider);
  final remote = ref.read(openFoodFactsRemoteDataSourceProvider);

  // 1. Get local results (scan limited to avoid blocking)
  final localResult = await local.searchLocalProducts(query.trim(), limit: 10);
  final localProducts = localResult.getOrElse((_) => <Product>[]);

  // 2. Get API results (may fail offline)
  final apiResult = await remote.searchProducts(query.trim(), pageSize: 15);
  final apiProducts = apiResult.getOrElse((_) => <Product>[]);

  // 3. Merge and deduplicate by barcode (prefer API data)
  final seenBarcodes = <String>{};
  final merged = <Product>[];

  for (final p in apiProducts) {
    if (p.barcode != null && !seenBarcodes.add(p.barcode!)) continue;
    merged.add(Product(
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
      source: 'api',
    ));
  }

  for (final p in localProducts) {
    if (p.barcode != null && !seenBarcodes.add(p.barcode!)) continue;
    if (p.name.toLowerCase().contains(query.trim().toLowerCase())) {
      merged.add(p);
    }
  }

  return merged;
});

/// Get product by barcode (local first, then API).
final productByBarcodeProvider = FutureProvider.family<Product?, String>((ref, barcode) async {
  if (barcode.trim().isEmpty) return null;

  final local = ref.read(openFoodFactsLocalDataSourceProvider);
  final remote = ref.read(openFoodFactsRemoteDataSourceProvider);

  // 1. Check local first
  final localResult = await local.getLocalProductByBarcode(barcode.trim());
  final cached = localResult.getOrElse((_) => null);
  if (cached != null) {
    // Optionally refresh from API in background (for now return cached)
    return cached;
  }

  // 2. Fetch from API
  final apiResult = await remote.getProductByBarcode(barcode.trim());
  return apiResult.fold(
    (_) => null,
    (product) {
      // Cache for future use
      local.saveProduct(product);
      return product;
    },
  );
});
