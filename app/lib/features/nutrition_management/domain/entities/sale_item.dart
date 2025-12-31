/// Sale item domain entity
/// 
/// Represents a sale item for meal planning and shopping.
/// This is a pure Dart class with no external dependencies.
class SaleItem {
  /// Unique identifier (UUID)
  final String id;

  /// Item name
  final String name;

  /// Category ('produce', 'meat', 'dairy', 'pantry')
  final String category;

  /// Store name
  final String store;

  /// Regular price
  final double regularPrice;

  /// Sale price
  final double salePrice;

  /// Discount percentage
  final double discountPercent;

  /// Unit ('lb', 'oz', 'each')
  final String unit;

  /// Valid from date
  final DateTime validFrom;

  /// Valid to date
  final DateTime validTo;

  /// Optional description
  final String? description;

  /// Optional image URL
  final String? imageUrl;

  /// Source ('api', 'manual', 'scraped')
  final String source;

  /// Creation timestamp
  final DateTime createdAt;

  /// Last update timestamp
  final DateTime updatedAt;

  /// Creates a SaleItem
  SaleItem({
    required this.id,
    required this.name,
    required this.category,
    required this.store,
    required this.regularPrice,
    required this.salePrice,
    required this.discountPercent,
    required this.unit,
    required this.validFrom,
    required this.validTo,
    this.description,
    this.imageUrl,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if sale is currently active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(validFrom) && now.isBefore(validTo);
  }

  /// Create a copy with updated fields
  SaleItem copyWith({
    String? id,
    String? name,
    String? category,
    String? store,
    double? regularPrice,
    double? salePrice,
    double? discountPercent,
    String? unit,
    DateTime? validFrom,
    DateTime? validTo,
    String? description,
    String? imageUrl,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SaleItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      store: store ?? this.store,
      regularPrice: regularPrice ?? this.regularPrice,
      salePrice: salePrice ?? this.salePrice,
      discountPercent: discountPercent ?? this.discountPercent,
      unit: unit ?? this.unit,
      validFrom: validFrom ?? this.validFrom,
      validTo: validTo ?? this.validTo,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          category == other.category &&
          store == other.store &&
          regularPrice == other.regularPrice &&
          salePrice == other.salePrice &&
          discountPercent == other.discountPercent &&
          unit == other.unit &&
          validFrom == other.validFrom &&
          validTo == other.validTo &&
          description == other.description &&
          imageUrl == other.imageUrl &&
          source == other.source;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      category.hashCode ^
      store.hashCode ^
      regularPrice.hashCode ^
      salePrice.hashCode ^
      discountPercent.hashCode ^
      unit.hashCode ^
      validFrom.hashCode ^
      validTo.hashCode ^
      description.hashCode ^
      imageUrl.hashCode ^
      source.hashCode;

  @override
  String toString() {
    return 'SaleItem(id: $id, name: $name, store: $store, salePrice: $salePrice, discountPercent: ${discountPercent.toStringAsFixed(1)}%)';
  }
}

