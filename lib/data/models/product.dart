
import '../../utils/vat_helper.dart';

class Product {
  final String id;
  final String name;
  final String slug;
  final String? description;
  final Map<String, dynamic>? detailedDescription;
  final int price;
  final int? comparePrice;
  final int? costPrice;
  final int stock;
  final String? categoryId;
  final String? brand;
  final String? model;
  final String? colorway;
  final String? sku;
  final bool isLimitedEdition;
  final bool isFeatured;
  final bool isActive;
  final Map<String, dynamic> sizesAvailable;
  final List<String> images;
  final List<String> tags;
  final DateTime createdAt;
  // Discount fields
  final String? discountType;  // 'percentage' | 'fixed'
  final double? discountValue;
  // Release / collection fields
  final String? releaseType;   // 'standard' | 'new' | 'restock'
  final String? releaseDate;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.detailedDescription,
    required this.price,
    this.comparePrice,
    this.costPrice,
    required this.stock,
    this.categoryId,
    this.brand,
    this.model,
    this.colorway,
    this.sku,
    required this.isLimitedEdition,
    required this.isFeatured,
    required this.isActive,
    required this.sizesAvailable,
    required this.images,
    required this.tags,
    required this.createdAt,
    this.discountType,
    this.discountValue,
    this.releaseType,
    this.releaseDate,
  });

  // ─── Computed getters ───────────────────────────────────────────────────────

  /// Whether this product has an active discount
  bool get hasDiscount =>
      discountValue != null && discountValue! > 0 && discountType != null;

  /// Final price after discount (in cents/integer cents, same unit as [price])
  int get effectivePrice {
    if (!hasDiscount) return price;
    if (discountType == 'percentage') {
      final discounted = price * (1 - discountValue! / 100);
      return discounted.round();
    } else {
      // fixed: discountValue is in cents
      final discountCents = (discountValue! * 100).round();
      final discounted = price - discountCents;
      return discounted < 0 ? 0 : discounted;
    }
  }

  /// Precio base CON IVA (lo que ve el usuario)
  int get priceWithVat => VatHelper.priceWithVat(price);

  /// Precio efectivo (con descuento) CON IVA
  int get effectivePriceWithVat => VatHelper.priceWithVat(effectivePrice);

  /// Importe del IVA sobre el precio efectivo
  int get vatAmountOnEffective => VatHelper.vatAmount(effectivePrice);

  /// Human-readable discount badge label: "-20%" or "-10€"
  String get discountLabel {
    if (!hasDiscount) return '';
    if (discountType == 'percentage') {
      return '-${discountValue!.toStringAsFixed(0)}%';
    } else {
      return '-${discountValue!.toStringAsFixed(0)}€';
    }
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      detailedDescription: json['detailed_description'] as Map<String, dynamic>?,
      price: (json['price'] as num).toInt(),
      comparePrice: (json['compare_price'] as num?)?.toInt(),
      costPrice: (json['cost_price'] as num?)?.toInt(),
      stock: ((json['stock'] as num?) ?? 0).toInt(),
      categoryId: json['category_id'] as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      colorway: json['colorway'] as String?,
      sku: json['sku'] as String?,
      isLimitedEdition: json['is_limited_edition'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      sizesAvailable: json['sizes_available'] as Map<String, dynamic>? ?? {},
      images: List<String>.from(json['images'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
      discountType: json['discount_type'] as String?,
      discountValue: (json['discount_value'] as num?)?.toDouble(),
      releaseType: json['release_type'] as String?,
      releaseDate: json['release_date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'detailed_description': detailedDescription,
      'price': price,
      'compare_price': comparePrice,
      'cost_price': costPrice,
      'stock': stock,
      'category_id': categoryId,
      'brand': brand,
      'model': model,
      'colorway': colorway,
      'sku': sku,
      'is_limited_edition': isLimitedEdition,
      'is_featured': isFeatured,
      'is_active': isActive,
      'sizes_available': sizesAvailable,
      'images': images,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'discount_type': discountType,
      'discount_value': discountValue,
      'release_type': releaseType,
      'release_date': releaseDate,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? slug,
    String? description,
    Map<String, dynamic>? detailedDescription,
    int? price,
    int? comparePrice,
    int? costPrice,
    int? stock,
    String? categoryId,
    String? brand,
    String? model,
    String? colorway,
    String? sku,
    bool? isLimitedEdition,
    bool? isFeatured,
    bool? isActive,
    Map<String, dynamic>? sizesAvailable,
    List<String>? images,
    List<String>? tags,
    DateTime? createdAt,
    String? discountType,
    double? discountValue,
    String? releaseType,
    String? releaseDate,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      detailedDescription: detailedDescription ?? this.detailedDescription,
      price: price ?? this.price,
      comparePrice: comparePrice ?? this.comparePrice,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      colorway: colorway ?? this.colorway,
      sku: sku ?? this.sku,
      isLimitedEdition: isLimitedEdition ?? this.isLimitedEdition,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      sizesAvailable: sizesAvailable ?? this.sizesAvailable,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      releaseType: releaseType ?? this.releaseType,
      releaseDate: releaseDate ?? this.releaseDate,
    );
  }
}
