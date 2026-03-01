import 'package:freezed_annotation/freezed_annotation.dart';
import '../../utils/vat_helper.dart';

part 'product.freezed.dart';
part 'product.g.dart';

/// Helpers for JSON fields that come from Supabase in non-standard shapes.
Map<String, dynamic> _sizesFromJson(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

List<String> _stringListFromJson(dynamic v) =>
    v is List ? List<String>.from(v) : <String>[];

DateTime _dateTimeFromJson(dynamic v) =>
    v is String ? DateTime.parse(v) : DateTime.now();

int _intFromJson(dynamic v) => (v as num?)?.toInt() ?? 0;

@freezed
abstract class Product with _$Product {
  const Product._(); // Para permitir métodos personalizados
  const factory Product({
    required String id,
    required String name,
    required String slug,
    String? description,
    Map<String, dynamic>? detailedDescription,
    required int price,
    int? comparePrice,
    int? costPrice,
    @JsonKey(fromJson: _intFromJson) @Default(0) int stock,
    String? categoryId,
    String? brand,
    @JsonKey(name: 'model') String? productModel,
    String? colorway,
    String? sku,
    @Default(false) bool isLimitedEdition,
    @Default(false) bool isFeatured,
    @Default(true) bool isActive,
    @JsonKey(fromJson: _sizesFromJson) @Default({}) Map<String, dynamic> sizesAvailable,
    @JsonKey(fromJson: _stringListFromJson) @Default([]) List<String> images,
    @JsonKey(fromJson: _stringListFromJson) @Default([]) List<String> tags,
    @JsonKey(fromJson: _dateTimeFromJson) required DateTime createdAt,
    String? discountType,
    double? discountValue,
    String? releaseType,
    String? releaseDate,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);

  // ─── Computed getters ─────────────────────────────────────────────

  /// Whether this product has an active discount
  bool get hasDiscount =>
      discountValue != null && discountValue! > 0 && discountType != null;

  /// Final price after discount (cents)
  int get effectivePrice {
    if (!hasDiscount) return price;
    if (discountType == 'percentage') {
      return (price * (1 - discountValue! / 100)).round();
    } else {
      final discountCents = (discountValue! * 100).round();
      final discounted = price - discountCents;
      return discounted < 0 ? 0 : discounted;
    }
  }

  /// Precio base CON IVA
  int get priceWithVat => VatHelper.priceWithVat(price);

  /// Precio efectivo (con descuento) CON IVA
  int get effectivePriceWithVat => VatHelper.priceWithVat(effectivePrice);

  /// Importe del IVA sobre el precio efectivo
  int get vatAmountOnEffective => VatHelper.vatAmount(effectivePrice);

  /// Human-readable discount badge label
  String get discountLabel {
    if (!hasDiscount) return '';
    if (discountType == 'percentage') {
      return '-${discountValue!.toStringAsFixed(0)}%';
    } else {
      return '-${discountValue!.toStringAsFixed(0)}€';
    }
  }
}
