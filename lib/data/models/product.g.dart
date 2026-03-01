// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Product _$ProductFromJson(Map<String, dynamic> json) => _Product(
  id: json['id'] as String,
  name: json['name'] as String,
  slug: json['slug'] as String,
  description: json['description'] as String?,
  detailedDescription: json['detailed_description'] as Map<String, dynamic>?,
  price: (json['price'] as num).toInt(),
  comparePrice: (json['compare_price'] as num?)?.toInt(),
  costPrice: (json['cost_price'] as num?)?.toInt(),
  stock: json['stock'] == null ? 0 : _intFromJson(json['stock']),
  categoryId: json['category_id'] as String?,
  brand: json['brand'] as String?,
  productModel: json['model'] as String?,
  colorway: json['colorway'] as String?,
  sku: json['sku'] as String?,
  isLimitedEdition: json['is_limited_edition'] as bool? ?? false,
  isFeatured: json['is_featured'] as bool? ?? false,
  isActive: json['is_active'] as bool? ?? true,
  sizesAvailable: json['sizes_available'] == null
      ? const {}
      : _sizesFromJson(json['sizes_available']),
  images: json['images'] == null
      ? const []
      : _stringListFromJson(json['images']),
  tags: json['tags'] == null ? const [] : _stringListFromJson(json['tags']),
  createdAt: _dateTimeFromJson(json['created_at']),
  discountType: json['discount_type'] as String?,
  discountValue: (json['discount_value'] as num?)?.toDouble(),
  releaseType: json['release_type'] as String?,
  releaseDate: json['release_date'] as String?,
);

Map<String, dynamic> _$ProductToJson(_Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'slug': instance.slug,
  'description': instance.description,
  'detailed_description': instance.detailedDescription,
  'price': instance.price,
  'compare_price': instance.comparePrice,
  'cost_price': instance.costPrice,
  'stock': instance.stock,
  'category_id': instance.categoryId,
  'brand': instance.brand,
  'model': instance.productModel,
  'colorway': instance.colorway,
  'sku': instance.sku,
  'is_limited_edition': instance.isLimitedEdition,
  'is_featured': instance.isFeatured,
  'is_active': instance.isActive,
  'sizes_available': instance.sizesAvailable,
  'images': instance.images,
  'tags': instance.tags,
  'created_at': instance.createdAt.toIso8601String(),
  'discount_type': instance.discountType,
  'discount_value': instance.discountValue,
  'release_type': instance.releaseType,
  'release_date': instance.releaseDate,
};
