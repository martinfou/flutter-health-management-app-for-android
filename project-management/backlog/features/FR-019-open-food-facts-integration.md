# Feature Request: FR-019 - Open Food Facts Integration with Barcode Scanning

**Status**: ⭕ Not Started  
**Priority**: 🟠 High  
**Story Points**: 13  
**Created**: 2025-01-27  
**Updated**: 2025-01-27  
**Assigned Sprint**: Backlog

## Description

Integrate Open Food Facts API to enable users to retrieve nutritional information for food products by scanning barcodes or searching by product name. This feature will significantly streamline the meal logging process by automatically populating nutritional data from the Open Food Facts database, which contains information on over 3 million food products worldwide.

The integration will support:
- Barcode scanning using device camera
- Product lookup by barcode
- Product search by name
- Automatic population of nutritional values (protein, fats, carbs, calories, ingredients)
- Display of additional product information (Nutri-Score, allergens, additives, etc.)
- Quick meal logging from scanned/searched products

## User Story

As a user, I want to scan barcodes or search for food products to automatically retrieve their nutritional information, so that I can quickly log meals without manually entering nutritional data and ensure accurate nutrition tracking.

## Acceptance Criteria

- [ ] Add `openfoodfacts` package (^3.29.0) to dependencies
- [ ] Configure Open Food Facts SDK global settings (User-Agent, language, country)
- [ ] Add barcode scanning functionality using device camera
- [ ] Implement product lookup by barcode via Open Food Facts API
- [ ] Implement product search by name via Open Food Facts API
- [ ] Parse and map Open Food Facts SDK `Product` objects to app's Meal entity format:
  - Product name → meal name
  - Nutritional values (protein, fats, carbs, calories) → meal macros
  - Ingredients list → meal ingredients
- [ ] Display product information in a user-friendly format:
  - Product name and image (if available)
  - Nutritional values (protein, fats, net carbs, calories)
  - Ingredients list
  - Additional info: Nutri-Score, allergens, additives (if available)
- [ ] Allow user to adjust serving size/portion before logging
- [ ] Quick log button to create meal entry from product data
- [ ] Handle errors gracefully:
  - Product not found (barcode or search)
  - Network errors
  - Missing nutritional data
  - API rate limit errors
- [ ] Loading states during API calls and barcode scanning
- [ ] Respect Open Food Facts API rate limits (100 req/min for product queries)
- [ ] Implement caching to reduce API calls (cache product data locally)
- [ ] Configure SDK User-Agent via `OpenFoodAPIConfiguration.userAgent` (required by Open Food Facts API)
- [ ] Support manual barcode entry (fallback if camera unavailable)

## Business Value

This feature provides significant value by:

- **Improved User Experience**: Reduces meal logging time from minutes to seconds
- **Data Accuracy**: Ensures consistent, accurate nutritional data from a trusted source
- **Increased Engagement**: Removes friction from nutrition tracking, leading to better adherence
- **Comprehensive Database**: Access to 3+ million products worldwide
- **Professional Quality**: Nutri-Score, allergen information, and ingredient analysis enhance app value
- **User Retention**: Quick barcode scanning makes the app more convenient than manual entry

## Technical Requirements

### API Integration

- **Open Food Facts SDK**: 
  - Package: `openfoodfacts` (official Dart/Flutter SDK)
  - Version: `^3.29.0` (latest stable)
  - Package URL: https://pub.dev/packages/openfoodfacts
  - GitHub: https://github.com/openfoodfacts/openfoodfacts-dart
  - API Version: v2 (handled by SDK)
  - Rate Limits: 100 requests/minute for product queries, 10 requests/minute for search (handled by SDK)
  - Authentication: Not required for read operations, but User-Agent recommended
  
- **SDK Setup**:
  - Configure global settings at app startup:
    ```dart
    OpenFoodAPIConfiguration.userAgent = UserAgent(
      name: 'HealthApp', 
      url: 'https://your-app-url.com'
    );
    OpenFoodAPIConfiguration.globalLanguages = [OpenFoodFactsLanguage.ENGLISH];
    OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.US;
    ```
  - SDK provides typed objects and handles API communication
  - Supports product queries, search, autocomplete, and more

### Barcode Scanning

- **Package**: Use `mobile_scanner` or `google_mlkit_barcode_scanning` for Flutter barcode scanning
- **Permissions**: Camera permission required (already in use for progress photos)
- **Scanning Flow**:
  1. Open camera scanner
  2. Detect barcode (EAN-13, UPC-A, etc.)
  3. Extract barcode number
  4. Call Open Food Facts API with barcode
  5. Display product information
  6. Allow user to log meal

- **Manual Entry Fallback**: Text input field for barcode entry if camera unavailable

### Data Layer

- **New Data Source**: `OpenFoodFactsDataSource`
  - Location: `lib/features/nutrition_management/data/datasources/remote/open_food_facts_datasource.dart`
  - Uses `OpenFoodAPIClient` from `openfoodfacts` package
  - Methods:
    - `Future<Result<Product>> getProductByBarcode(String barcode)` - Uses `OpenFoodAPIClient.getProduct()`
    - `Future<Result<List<Product>>> searchProducts(String query, {int pageSize = 20})` - Uses `OpenFoodAPIClient.searchProducts()`
  - Maps SDK's `Product` objects to app's domain entities
  - Handles SDK exceptions and converts to app's `Failure` types
  
- **New Model/Entity**: `Product` (domain entity)
  - Location: `lib/features/nutrition_management/domain/entities/product.dart`
  - Represents product information from Open Food Facts
  - Fields: name, barcode, imageUrl, nutrition (protein, fats, carbs, calories), ingredients, nutriscore, allergens, additives
  - Maps from SDK's `Product` class (from `openfoodfacts` package) to domain entity
  - Handle missing/null fields gracefully (SDK handles nullable fields)
  
- **Repository Extension**: Extend `NutritionRepository` interface
  - Add methods for Open Food Facts integration (or create separate repository)
  - Location: `lib/features/nutrition_management/domain/repositories/nutrition_repository.dart`
  - Wraps data source calls with domain logic

### Use Cases

- **New Use Case**: `GetProductByBarcodeUseCase`
  - Location: `lib/features/nutrition_management/domain/usecases/get_product_by_barcode.dart`
  - Input: barcode string
  - Output: `Result<Product>`
  
- **New Use Case**: `SearchProductsUseCase`
  - Location: `lib/features/nutrition_management/domain/usecases/search_products.dart`
  - Input: search query string, page size
  - Output: `Result<List<Product>>`

### Presentation Layer

- **New Page**: `BarcodeScannerPage`
  - Location: `lib/features/nutrition_management/presentation/pages/barcode_scanner_page.dart`
  - Camera view for barcode scanning
  - Manual barcode entry option
  - Loading state while fetching product
  - Error states (product not found, network error)
  
- **New Page/Widget**: `ProductDetailWidget` or `ProductDetailPage`
  - Location: `lib/features/nutrition_management/presentation/pages/product_detail_page.dart`
  - Display product information
  - Serving size adjustment
  - Quick log button
  
- **New Widget**: `ProductSearchWidget`
  - Location: `lib/features/nutrition_management/presentation/widgets/product_search_widget.dart`
  - Search input field
  - Product results list
  - Tap to view product details
  
- **Integration**: Add "Scan Barcode" button to `MealLoggingPage`
  - Quick access to barcode scanner
  - Navigate to `BarcodeScannerPage`

### Caching Strategy

- **Local Cache**: Cache product data in Hive to reduce API calls
- **Cache Key**: Barcode or product ID
- **Cache Duration**: 7 days (products don't change frequently)
- **Cache Invalidation**: Manual refresh option, or when user requests fresh data

### Error Handling

- **Product Not Found**: 
  - Display friendly message: "Product not found in database"
  - Suggest manual entry or search alternative
  
- **Network Errors**: 
  - Display network error message
  - Offer retry option
  - Check connectivity
  
- **Missing Nutritional Data**:
  - Display available data
  - Allow user to manually fill missing fields
  - Show warning if critical data (calories, macros) is missing
  
- **Rate Limit Errors**:
  - Display message: "Too many requests. Please try again in a minute"
  - Implement request throttling/queueing
  - Use caching to reduce API calls

### Performance Considerations

- **Request Throttling**: Implement client-side rate limiting to stay within API limits
- **Debouncing**: Debounce search input (500ms) to reduce API calls
- **Pagination**: Implement pagination for search results
- **Image Loading**: Use image caching for product images
- **Background Processing**: Fetch product data in background while showing loading state

## Reference Documents

- Open Food Facts Dart SDK: https://pub.dev/packages/openfoodfacts
- Open Food Facts SDK Documentation: https://pub.dev/documentation/openfoodfacts/latest/index.html
- Open Food Facts SDK GitHub: https://github.com/openfoodfacts/openfoodfacts-dart
- Open Food Facts API Documentation: https://openfoodfacts.github.io/openfoodfacts-server/api/
- Open Food Facts API Tutorial: https://openfoodfacts.github.io/openfoodfacts-server/api/tutorial-off-api/
- Open Food Facts Terms of Use: https://world.openfoodfacts.org/terms-of-use

## Technical References

### Existing Code Structure

- Repository: `lib/features/nutrition_management/domain/repositories/nutrition_repository.dart`
- Repository Implementation: `lib/features/nutrition_management/data/repositories/nutrition_repository_impl.dart`
- Meal Entity: `lib/features/nutrition_management/domain/entities/meal.dart`
- Meal Model: `lib/features/nutrition_management/data/models/meal_model.dart`
- Meal Logging Page: `lib/features/nutrition_management/presentation/pages/meal_logging_page.dart`
- Log Meal Use Case: `lib/features/nutrition_management/domain/usecases/log_meal.dart`
- HTTP Client: `http` package (already in dependencies)

### Flutter Packages to Add

- **Open Food Facts SDK**: `openfoodfacts: ^3.29.0` (required)
- **Barcode Scanning**: `mobile_scanner` or `google_mlkit_barcode_scanning` (required)
- **Image Caching**: `cached_network_image` (optional, for product images)
- **HTTP**: `http` (already in dependencies, used by SDK)

## Dependencies

- **Required**:
  - `openfoodfacts: ^3.29.0` - Official Open Food Facts Dart SDK
  - Barcode scanning package (`mobile_scanner` or `google_mlkit_barcode_scanning`)
  - Camera permission (already configured for progress photos)
- **Optional**:
  - `cached_network_image` - For caching product images
- **Already Available**:
  - `http` package (used by SDK, already in dependencies)

## Notes

- **MVP Scope**: Focus on core functionality (barcode scanning, product lookup, quick meal logging). Advanced features (Nutri-Score display, detailed allergen info) can be enhanced later.
- **API Rate Limits**: Important to respect rate limits (100 req/min for product queries). Implement client-side throttling and caching.
- **Data Mapping**: SDK provides typed `Product` class with structured data. Need to map SDK's `Product` to app's domain entity:
  - `product.nutriments?.proteins100g` → protein (grams per 100g)
  - `product.nutriments?.fat100g` → fats (grams per 100g)
  - `product.nutriments?.carbohydrates100g` → carbs (calculate net carbs: carbs - fiber if available)
  - `product.nutriments?.energyKcal100g` → calories (per 100g)
  - `product.ingredientsText` → ingredients list
  - `product.nutriscore` → Nutri-Score grade
  - Serving size conversion needed (SDK provides per 100g, need to convert to user's serving size)
- **Net Carbs Calculation**: Open Food Facts provides total carbohydrates. Need to subtract fiber if available: `net_carbs = carbohydrates - fiber`
- **Serving Size**: Open Food Facts provides nutrition per 100g. Need to allow user to specify serving size and calculate accordingly.
- **Product Images**: Open Food Facts provides product images. Can enhance UI by displaying product images.
- **Offline Support**: Cached products can be viewed offline, but new scans require internet connection.
- **International Support**: Open Food Facts has products from many countries. Consider allowing users to select country/locale for better results.
- **Data Quality**: Open Food Facts is user-contributed. Some products may have incomplete data. Handle gracefully and allow manual override.
- **SDK Benefits**: Using official SDK provides:
  - Type safety with Dart classes
  - Automatic API version handling
  - Built-in error handling
  - Support for advanced features (autocomplete, product editing, images, etc.)
  - Regular updates and maintenance
- **Alternative**: Consider implementing both barcode scanning AND text search, as some products may not have barcodes or barcode may not be in database. SDK supports both via `getProduct()` and `searchProducts()`.
- **Testing**: Test with various barcode formats (EAN-13, UPC-A, etc.) and products from different countries. SDK handles barcode normalization.
- **Legal Compliance**: Ensure compliance with Open Food Facts license (Open Database License). Data can be used freely, but attribution may be required. SDK documentation includes license information.

## Implementation Phases (Optional Breakdown)

### Phase 1: Core API Integration
- Add `openfoodfacts` package to dependencies
- Configure SDK global settings
- Create data source using `OpenFoodAPIClient`
- Create product domain entity
- Map SDK's `Product` to domain entity
- Basic product lookup by barcode using `OpenFoodAPIClient.getProduct()`
- Error handling (map SDK exceptions to app failures)

### Phase 2: Barcode Scanning
- Add barcode scanning package
- Implement camera scanner UI
- Integrate scanner with API client
- Manual barcode entry fallback

### Phase 3: Product Display & Logging
- Product detail page/widget
- Serving size adjustment
- Quick meal logging integration
- Cache implementation

### Phase 4: Search Functionality
- Product search by name
- Search results UI
- Pagination
- Search integration with meal logging

### Phase 5: Polish & Enhancement
- Product images
- Nutri-Score display
- Allergen information
- Performance optimization
- Advanced caching

## History

- 2025-01-27 - Created

