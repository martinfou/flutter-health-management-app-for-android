# Feature Request: FR-019 - Open Food Facts Integration with Autocomplete and Barcode Scanning

**Status**: ⭕ Not Started
**Priority**: 🟠 High
**Story Points**: 13
**Created**: 2025-01-27
**Updated**: 2026-01-04
**Assigned Sprint**: [Sprint 20](../../sprints/sprint-20-open-food-facts-integration.md)

## Description

Integrate Open Food Facts API directly into the meal logging workflow to enable users to retrieve nutritional information for food products via autocomplete search and barcode scanning. This feature will significantly streamline the meal logging process by automatically populating nutritional data from the Open Food Facts database, which contains information on over 3 million food products worldwide.

The integration will support:
- **Autocomplete search**: As users type in the food name field, display a dropdown list of matching products with their nutritional values
- **Barcode scanning**: Scan product barcodes using device camera to retrieve nutritional information
- **Product lookup by barcode**: Retrieve product information directly from barcode number
- **Automatic population**: Pre-fill nutritional values (protein, fats, carbs, calories, ingredients) in the add food dialog
- **Display of additional product information**: Show Nutri-Score, allergens, additives, etc. when available
- **Seamless integration**: All functionality integrated directly into the `_AddFoodItemDialog` on the meal logging screen

## User Story

As a user, I want to search for food products using autocomplete or scan barcodes directly in the add food dialog, so that I can quickly log meals with accurate nutritional data without manually entering values.

## Acceptance Criteria

### SDK Setup
- [ ] Add `openfoodfacts` package (^3.29.0) to dependencies
- [ ] Configure Open Food Facts SDK global settings (User-Agent, language, country)
- [ ] Configure SDK User-Agent via `OpenFoodAPIConfiguration.userAgent` (required by Open Food Facts API)

### Autocomplete Integration in Add Food Dialog
- [ ] Implement autocomplete search in the `_AddFoodItemDialog` food name field (`_nameController`)
- [ ] Implement dual-mode search (local-first, API-fallback):
  - Query local database first (instant results, <10ms)
  - Display local results immediately in dropdown
  - Query Open Food Facts API in background
  - Update dropdown when API results arrive
  - Merge local and API results (deduplicate by barcode)
- [ ] As user types (debounced 500ms), display dropdown list of matching products
- [ ] Each autocomplete suggestion shows:
  - Product name
  - Brief nutritional info (calories per 100g, key macros)
  - Product image thumbnail (if available)
  - Source indicator (local common food vs API result)
- [ ] Prioritize local common foods in results list
- [ ] Show subtle loading indicator for API search (local results visible first)
- [ ] User can select a product from autocomplete dropdown
- [ ] Upon selection, automatically populate all fields in the dialog:
  - Product name → food name field
  - Nutritional values → protein, fats, net carbs, calories fields
  - Ingredients list → ingredients field
- [ ] Allow user to modify any auto-populated values before saving
- [ ] Handle autocomplete errors gracefully (network errors, rate limits, no results)
- [ ] Work offline (local search works without network, API search skipped)

### Barcode Scanning Integration in Add Food Dialog
- [ ] Add barcode scanning button/icon next to the food name field in `_AddFoodItemDialog`
- [ ] Implement barcode scanning functionality using device camera (`mobile_scanner` or `google_mlkit_barcode_scanning`)
- [ ] On scan, implement dual-mode lookup:
  - Check local database first (instant result if found)
  - If found locally → Display product immediately and auto-populate fields
  - Query Open Food Facts API in background
  - If API result differs or local not found → Update with API data
  - Cache API result for future use
- [ ] Auto-populate all fields in the dialog with scanned product data (same as autocomplete selection)
- [ ] Support manual barcode entry fallback (text input if camera unavailable)
- [ ] Display loading state during API lookup (product displayed immediately if found locally)

### Data Mapping
- [ ] Parse and map Open Food Facts SDK `Product` objects to app's FoodItem format:
  - Product name → food name
  - Nutritional values (protein, fats, carbs, calories) → food macros
  - Ingredients list → food ingredients
- [ ] Handle serving size conversion (Open Food Facts provides per 100g, allow user to specify serving size)
- [ ] Calculate net carbs correctly (carbohydrates - fiber if available)

### Error Handling
- [ ] Handle errors gracefully:
  - Product not found (barcode or search)
  - Network errors
  - Missing nutritional data
  - API rate limit errors
- [ ] Display user-friendly error messages in the dialog
- [ ] Allow manual entry fallback when product lookup fails

### Local Database & Seeding
- [ ] Create `ProductModel` Hive type adapter for local storage
- [ ] Create `OpenFoodFactsLocalDataSource` for local database operations
- [ ] Implement local search functionality (full-text search on product names)
- [ ] Create common foods seed data file (500-1000 products, <5MB)
- [ ] Implement seed data loading on first app launch
- [ ] Implement seed data version tracking and updates
- [ ] Create Hive box for products (`HiveBoxNames.products` or similar)

### Performance & Caching
- [ ] Implement dual-mode search (local-first, API-fallback)
- [ ] Display local results immediately (optimistic UI pattern)
- [ ] Query API in background and update results when available
- [ ] Merge local and API results (deduplicate by barcode)
- [ ] Implement request debouncing for autocomplete (500ms delay)
- [ ] Respect Open Food Facts API rate limits (100 req/min for product queries, 10 req/min for search)
- [ ] Implement cache auto-population (cache all API search/barcode results)
- [ ] Implement cache eviction (30 days for user cache, LRU when size limit reached)
- [ ] Display loading states during API calls (subtle indicator, local results shown first)
- [ ] Implement request throttling to stay within API limits
- [ ] Limit local cache size (max 5000 products, ~10MB)

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

- **New Data Source**: `OpenFoodFactsDataSource` (Remote)
  - Location: `lib/features/nutrition_management/data/datasources/remote/open_food_facts_datasource.dart`
  - Uses `OpenFoodAPIClient` from `openfoodfacts` package
  - Methods:
    - `Future<Result<Product>> getProductByBarcode(String barcode)` - Uses `OpenFoodAPIClient.getProduct()`
    - `Future<Result<List<Product>>> searchProducts(String query, {int pageSize = 20})` - Uses `OpenFoodAPIClient.searchProducts()`
    - `Future<Result<List<Product>>> autocompleteProducts(String query, {int limit = 10})` - Uses `OpenFoodAPIClient.searchProducts()` with limit for autocomplete
  - Maps SDK's `Product` objects to app's domain entities
  - Handles SDK exceptions and converts to app's `Failure` types
  - Implements request throttling to respect API rate limits
  
- **New Data Source**: `OpenFoodFactsLocalDataSource` (Local)
  - Location: `lib/features/nutrition_management/data/datasources/local/open_food_facts_local_datasource.dart`
  - Uses Hive for local product storage
  - Methods:
    - `Future<Result<List<Product>>> searchLocalProducts(String query, {int limit = 10})` - Search common foods in local database
    - `Future<Result<Product>> getLocalProductByBarcode(String barcode)` - Get product by barcode from local database
    - `Future<Result<void>> saveProducts(List<Product> products)` - Save products to local database (for common foods and cache)
    - `Future<Result<void>> seedCommonFoods()` - Seed initial common foods database
  - Handles Hive operations and converts exceptions to app's `Failure` types
  - Manages local product database with indexing for fast search
  
- **New Hive Box**: `ProductModel` (Hive Type Adapter)
  - Location: `lib/features/nutrition_management/data/models/product_model.dart`
  - Extends `HiveObject` for local storage
  - Fields: name, barcode, imageUrl, nutrition (protein, fats, carbs, calories), ingredients, nutriscore, allergens, additives, source (local/common/cached), lastUpdated
  - Indexes: name (full-text search), barcode (unique), category (for filtering)
  - Serialization/deserialization for Hive storage
  
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
  
- **New Use Case**: `AutocompleteProductsUseCase`
  - Location: `lib/features/nutrition_management/domain/usecases/autocomplete_products.dart`
  - Input: search query string, limit (default 10)
  - Output: `Result<List<Product>>` (or `Stream<List<Product>>` for real-time updates)
  - Implements dual-mode search: queries local database first, then API
  - Returns local results immediately, updates with API results as they arrive
  - Used for autocomplete dropdown suggestions
  
- **New Use Case**: `GetProductByBarcodeUseCase` (Enhanced)
  - Location: `lib/features/nutrition_management/domain/usecases/get_product_by_barcode.dart`
  - Input: barcode string
  - Output: `Result<Product>` (or `Stream<Product>` for optimistic updates)
  - Checks local database first, then queries API if not found
  - Caches API result for future use

### Presentation Layer

- **Enhanced Dialog**: `_AddFoodItemDialog` in `meal_logging_page.dart`
  - Location: `lib/features/nutrition_management/presentation/pages/meal_logging_page.dart`
  - **Autocomplete Integration**: 
    - Convert food name `TextFormField` to support autocomplete
    - Display dropdown list of products as user types
    - **Dual-mode search**: Show local results immediately, update with API results
    - Debounce search requests (500ms)
    - Show product suggestions with name, nutrition preview, and image thumbnail
    - Indicate source (local common food vs API result) with subtle visual indicator
    - Handle product selection and auto-populate all fields
    - Show loading indicator for API search (local results visible first)
  - **Barcode Scanning Integration**:
    - Add barcode scanner icon/button next to food name field
    - Open camera scanner on tap (using `mobile_scanner` or `google_mlkit_barcode_scanning`)
    - Scan barcode and fetch product via Open Food Facts API
    - Auto-populate all fields with scanned product data
    - Manual barcode entry fallback option
  - Loading states during API calls
  - Error handling with user-friendly messages
  
- **New Widget**: `ProductAutocompleteWidget` (optional, for reusability)
  - Location: `lib/features/nutrition_management/presentation/widgets/product_autocomplete_widget.dart`
  - Reusable autocomplete widget for product search
  - Can be used within `_AddFoodItemDialog` or other contexts
  - Handles search, debouncing, and product selection
  
- **New Widget**: `BarcodeScannerWidget` (optional, for reusability)
  - Location: `lib/features/nutrition_management/presentation/widgets/barcode_scanner_widget.dart`
  - Reusable barcode scanner widget
  - Camera view with barcode detection
  - Returns scanned barcode to parent widget
  - Can be shown as bottom sheet or dialog

### Local Database & Caching Strategy

#### Dual-Mode Search Strategy

The search implementation uses a **local-first, API-fallback** approach:

1. **Local Search (Immediate)**: 
   - Query local Hive database for common foods and cached products
   - Display results instantly (no network delay)
   - Results appear immediately in autocomplete dropdown

2. **API Search (Background)**:
   - Simultaneously query Open Food Facts API
   - Update autocomplete dropdown when API results arrive
   - Merge local and API results (deduplicate by barcode/product ID)
   - Mark source (local vs API) for user transparency

3. **Optimistic UI Pattern**:
   - Show local results immediately (0ms delay)
   - Update with API results as they arrive (typically 200-500ms)
   - Indicate loading state for API search (subtle indicator)
   - Prioritize local common foods in results list

#### Local Database Structure

- **Common Foods Database**: Pre-seeded local database of ~500-1000 most common food items
  - Location: Hive box `HiveBoxNames.products` (or `common_foods`)
  - Seed data: Curated list of frequently searched foods (chicken, rice, bread, etc.)
  - Update frequency: Bundled with app updates, can be refreshed via settings
  - Storage: ~2-5MB compressed, includes essential nutritional data
  
- **Cache Database**: User-scanned/searched products cached locally
  - Same Hive box as common foods
  - Auto-populated from API searches and barcode scans
  - Cache duration: 30 days (longer than API cache for offline access)
  - Cache eviction: LRU (Least Recently Used) when box reaches size limit (max 5000 items)
  
- **Indexing Strategy**:
  - Full-text search index on product name (for fast local search)
  - Unique index on barcode (for O(1) barcode lookups)
  - Category index (optional, for filtering)
  - Implemented using Hive's built-in indexing or custom search logic

#### Common Foods Seeding Strategy

**Initial Seed Data**:
- Include ~500-1000 most common foods in app bundle (JSON file or Hive backup)
- Categories: Proteins, Carbs, Vegetables, Fruits, Dairy, Common packaged foods
- Data source: Curated subset from Open Food Facts (most popular products)
- Format: Pre-processed JSON or Hive box backup included in app assets
- Size: Target <5MB compressed

**Seeding Implementation**:
- Seed on first app launch (if database is empty)
- Seed in background during app initialization
- Optional: Allow user to refresh seed data from settings
- Version control: Track seed data version, update with app updates

**Seed Data Selection Criteria**:
- Most frequently searched products globally
- Common whole foods (chicken, rice, eggs, etc.)
- Popular packaged products (major brands)
- Regional variants (consider user's locale/country)
- Complete nutritional data (no missing macros)

#### Caching Strategy

- **Local Cache (Common Foods + User Cache)**:
  - Storage: Hive box for products
  - Cache Key: Barcode (primary) or Product ID
  - Cache Duration: 
    - Common foods: Permanent (updated with app updates)
    - User-searched products: 30 days
  - Cache Invalidation: 
    - Manual refresh option in settings
    - Automatic eviction after 30 days of non-use
    - LRU eviction when cache size limit reached (5000 items max)
  
- **Cache Population**:
  - Auto-cache all API search results
  - Auto-cache all barcode scan results
  - Cache on product selection (pre-cache for future searches)
  - Background pre-caching for popular searches

- **Cache Performance**:
  - Local search: <10ms (instant)
  - Cache lookup: <5ms (Hive key-based lookup)
  - Storage efficiency: ~1-2KB per product (compressed)
  - Total cache size: Max 10MB (5000 products * ~2KB)

#### Search Flow Implementation

**Autocomplete Search Flow**:
1. User types in food name field
2. Debounce 500ms
3. **Immediate**: Query local database → Display results instantly
4. **Background**: Query Open Food Facts API
5. When API results arrive:
   - Merge with local results (deduplicate by barcode)
   - Sort by relevance (local common foods first, then API results)
   - Update autocomplete dropdown
6. User selects product → Auto-populate fields

**Barcode Scan Flow**:
1. User scans barcode
2. **Immediate**: Check local database for barcode
3. If found locally → Display product immediately
4. **Background**: Query Open Food Facts API
5. If API result differs or local not found → Update with API data
6. Cache API result for future use
7. Auto-populate fields with product data

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
- **Local-First Performance**: Local search returns in <10ms (instant user feedback)
- **Optimistic UI**: Show local results immediately, update with API results asynchronously
- **Pagination**: Implement pagination for API search results (local search can return all matches)
- **Image Loading**: Use image caching for product images (cached_network_image package)
- **Background Processing**: Fetch product data in background while showing local results
- **Cache Efficiency**: Limit local cache size (5000 products max) with LRU eviction
- **Storage Optimization**: Compress seed data, use efficient Hive serialization
- **Search Indexing**: Full-text search index on product names for fast local queries

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
- Local Data Source: `lib/features/nutrition_management/data/datasources/local/nutrition_local_datasource.dart` (reference for Hive patterns)
- Meal Entity: `lib/features/nutrition_management/domain/entities/meal.dart`
- Meal Model: `lib/features/nutrition_management/data/models/meal_model.dart` (reference for Hive type adapter)
- Meal Logging Page: `lib/features/nutrition_management/presentation/pages/meal_logging_page.dart`
- Log Meal Use Case: `lib/features/nutrition_management/domain/usecases/log_meal.dart`
- HTTP Client: `http` package (already in dependencies)
- Hive Box Names: `lib/core/providers/database_provider.dart` or `lib/core/constants/hive_box_names.dart` (reference for box naming)

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
- **Local Database Benefits**: 
  - Instant search results (no network delay)
  - Offline access to common foods
  - Reduced API calls (better rate limit compliance)
  - Improved user experience (optimistic UI)
  - Lower data usage for users
- **Seed Data Strategy**: 
  - Include common foods in app bundle (JSON or Hive backup)
  - Target 500-1000 most popular products
  - Update seed data with app releases
  - Consider regional variants (different seed data per country/locale)
- **Cache Strategy Rationale**:
  - 30-day cache for user-searched products (longer than API cache for offline access)
  - LRU eviction prevents unbounded growth
  - 5000 product limit balances storage vs. utility
  - Common foods are permanent (updated only with app updates)
- **Testing**: 
  - Test local search performance (<10ms response time)
  - Test dual-mode search (local results appear, API updates)
  - Test cache eviction and size limits
  - Test with various barcode formats (EAN-13, UPC-A, etc.) and products from different countries
  - Test offline mode (local search works without network)
  - SDK handles barcode normalization
- **Legal Compliance**: 
  - Ensure compliance with Open Food Facts license (Open Database License)
  - Data can be used freely, but attribution may be required
  - Seed data must comply with Open Database License (can include Open Food Facts data)
  - SDK documentation includes license information

## Implementation Phases (Optional Breakdown)

### Phase 1: Local Database Foundation
- Create `ProductModel` Hive type adapter
- Create `OpenFoodFactsLocalDataSource` for local operations
- Create Hive box for products
- Implement local search functionality
- Create common foods seed data (JSON file with 500-1000 products)
- Implement seed data loading on first launch
- Test local search performance

### Phase 2: Core API Integration
- Add `openfoodfacts` package to dependencies
- Configure SDK global settings
- Create remote data source using `OpenFoodAPIClient`
- Create product domain entity
- Map SDK's `Product` to domain entity
- Basic product lookup by barcode using `OpenFoodAPIClient.getProduct()`
- Error handling (map SDK exceptions to app failures)

### Phase 3: Dual-Mode Search Implementation
- Implement `AutocompleteProductsUseCase` with dual-mode logic
- Query local database first (instant results)
- Query API in background (update results)
- Merge local and API results (deduplicate)
- Implement optimistic UI pattern
- Test dual-mode search flow

### Phase 4: Barcode Scanning
- Add barcode scanning package
- Implement camera scanner UI/widget
- Integrate scanner with local + API lookup
- Check local database first, then API
- Cache scanned products
- Manual barcode entry fallback

### Phase 5: Autocomplete Integration in Dialog
- Integrate autocomplete into `_AddFoodItemDialog`
- Display local results immediately
- Update with API results as they arrive
- Auto-populate fields on selection
- Loading states and error handling

### Phase 6: Caching & Performance
- Implement cache auto-population (cache API results)
- Implement cache eviction (30 days, LRU)
- Implement cache size limits (5000 products)
- Optimize local search indexing
- Performance testing and optimization

### Phase 7: Polish & Enhancement
- Product images in autocomplete
- Nutri-Score display
- Allergen information
- Source indicators (local vs API)
- Seed data updates mechanism
- Offline mode testing

## History

- 2025-01-27 - Created
- 2026-01-03 - Status updated to ⭕ Not Started
  - No Open Food Facts integration in codebase
  - No barcode scanning functionality implemented
  - openfoodfacts package not added to dependencies
- 2026-01-04 - Enhanced to explicitly include autocomplete and barcode scanning integration in add food dialog
  - Added detailed acceptance criteria for autocomplete in `_AddFoodItemDialog`
  - Added detailed acceptance criteria for barcode scanning in `_AddFoodItemDialog`
  - Clarified integration approach (directly in dialog, not separate pages)
  - Added autocomplete use case and data source method
- 2026-01-04 - Added local database strategy with dual-mode search
  - Added local database structure (Hive-based)
  - Added common foods seeding strategy (500-1000 products)
  - Implemented dual-mode search (local-first, API-fallback)
  - Added optimistic UI pattern (show local results immediately, update with API)
  - Added comprehensive caching strategy (30-day cache, LRU eviction, size limits)
  - Updated implementation phases to include local database foundation
  - Added performance considerations for local search

