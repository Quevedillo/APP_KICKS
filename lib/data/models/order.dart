import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';

// ─── OrderItem ──────────────────────────────────────────────────────────────

@freezed
abstract class OrderItem with _$OrderItem {
  const factory OrderItem({
    required String productId,
    required String productName,
    @Default('') String productBrand,
    @Default('') String productImage,
    required int price,
    required String size,
    @Default(1) int quantity,
  }) = _OrderItem;

  /// Custom factory because the JSON from Supabase can have nested `product`
  /// objects, aliased keys (`qty` vs `quantity`), etc.
  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    final priceValue = json['price'] ?? product?['price'] ?? 0;
    final quantityValue = json['quantity'] ?? json['qty'] ?? 1;

    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    }

    return OrderItem(
      productId: json['product_id'] as String? ?? product?['id'] as String? ?? '',
      productName: product?['name'] as String? ?? json['name'] as String? ?? '',
      productBrand: product?['brand'] as String? ?? json['brand'] as String? ?? '',
      productImage: (product?['images'] as List?)?.firstOrNull?.toString() ?? json['image'] as String? ?? '',
      price: safeInt(priceValue),
      size: json['size'] as String? ?? '',
      quantity: safeInt(quantityValue),
    );
  }

  /// Produces a simpler JSON for storage in the orders.items JSONB column.
  static Map<String, dynamic> toStorageJson(OrderItem item) => {
        'product_id': item.productId,
        'name': item.productName,
        'brand': item.productBrand,
        'image': item.productImage,
        'price': item.price,
        'size': item.size,
        'quantity': item.quantity,
      };
}

// ─── Helpers ────────────────────────────────────────────────────────────────

int _safeParseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  if (value is double) return value.toInt();
  return 0;
}

int? _safeParseNullableInt(dynamic value) {
  if (value == null) return null;
  return _safeParseInt(value);
}

DateTime _dateTimeFromJsonOrNow(dynamic v) =>
    v is String ? (DateTime.tryParse(v) ?? DateTime.now()) : DateTime.now();

DateTime? _nullableDateTimeFromJson(dynamic v) =>
    v is String ? DateTime.tryParse(v) : null;

Map<String, dynamic>? _parseShippingAddress(dynamic address) {
  if (address == null) return null;
  if (address is Map<String, dynamic>) return address;
  if (address is Map) return Map<String, dynamic>.from(address);
  if (address is String) {
    try {
      final decoded = jsonDecode(address);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
  }
  return null;
}

List<OrderItem> _parseItems(dynamic itemsData) {
  if (itemsData == null) return [];
  if (itemsData is String) {
    try {
      final decoded = jsonDecode(itemsData);
      if (decoded is List) {
        return decoded
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }
  if (itemsData is List) {
    return itemsData
        .map((e) {
          if (e is Map<String, dynamic>) return OrderItem.fromJson(e);
          if (e is Map) return OrderItem.fromJson(Map<String, dynamic>.from(e));
          if (e is String) {
            try {
              return OrderItem.fromJson(
                  jsonDecode(e) as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          }
          return null;
        })
        .whereType<OrderItem>()
        .toList();
  }
  return [];
}

// ─── Order ──────────────────────────────────────────────────────────────────

@freezed
abstract class Order with _$Order {
  const Order._(); // enable custom getters

  const factory Order({
    required String id,
    String? stripeSessionId,
    String? stripePaymentIntentId,
    @Default('') String userId,
    required int totalPrice,
    int? subtotalAmount,
    int? shippingAmount,
    int? discountAmount,
    String? discountCodeId,
    @Default('pending') String status,
    String? returnStatus,
    String? cancelledReason,
    @Default([]) List<OrderItem> items,
    String? shippingName,
    String? shippingEmail,
    String? shippingPhone,
    Map<String, dynamic>? shippingAddress,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _Order;

  /// Custom fromJson because Supabase returns items as JSONB (string OR list),
  /// shipping_address as JSONB (string OR map), and total as either
  /// `total_amount` or `total_price`.
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String? ?? '',
      stripeSessionId: json['stripe_session_id'] as String?,
      stripePaymentIntentId: json['stripe_payment_intent_id'] as String?,
      userId: json['user_id'] as String? ?? '',
      totalPrice: _safeParseInt(json['total_amount'] ?? json['total_price']),
      subtotalAmount: _safeParseNullableInt(json['subtotal_amount']),
      shippingAmount: _safeParseNullableInt(json['shipping_amount']),
      discountAmount: _safeParseNullableInt(json['discount_amount']),
      discountCodeId: json['discount_code_id'] as String?,
      status: json['status'] as String? ?? 'pending',
      returnStatus: json['return_status'] as String?,
      cancelledReason: json['cancelled_reason'] as String?,
      items: _parseItems(json['items']),
      shippingName: json['shipping_name'] as String?,
      shippingEmail:
          (json['billing_email'] ?? json['shipping_email']) as String?,
      shippingPhone: json['shipping_phone'] as String?,
      shippingAddress: _parseShippingAddress(json['shipping_address']),
      createdAt: _dateTimeFromJsonOrNow(json['created_at']),
      updatedAt: _nullableDateTimeFromJson(json['updated_at']),
    );
  }

  // ─── Computed getters ─────────────────────────────────────────────

  String get displayId {
    if (stripeSessionId != null && stripeSessionId!.length >= 8) {
      return stripeSessionId!
          .substring(stripeSessionId!.length - 8)
          .toUpperCase();
    }
    return id.length >= 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
  }

  String get statusLabel {
    switch (status) {
      case 'completed':
        return 'Completado';
      case 'pending':
        return 'Pendiente';
      case 'paid':
        return 'Pagado';
      case 'processing':
        return 'Procesando';
      case 'shipped':
        return 'Enviado';
      case 'delivered':
        return 'Entregado';
      case 'failed':
        return 'Fallido';
      case 'cancelled':
        return 'Cancelado';
      case 'refunded':
        return 'Reembolsado';
      default:
        return status;
    }
  }

  bool get canCancel => ['paid', 'processing'].contains(status);
  bool get canRequestRefund =>
      ['shipped', 'delivered'].contains(status) && returnStatus == null;

  /// Generar datos para factura PDF
  Map<String, dynamic> toInvoiceData() {
    return {
      'invoiceNumber': 'KP-$displayId',
      'orderId': id,
      'date': createdAt.toIso8601String(),
      'customerName': shippingName ?? 'Cliente',
      'customerEmail': shippingEmail ?? '',
      'customerPhone': shippingPhone ?? '',
      'shippingAddress': shippingAddress != null
          ? [
              shippingAddress!['line1'],
              shippingAddress!['line2'],
              '${shippingAddress!['postal_code']} ${shippingAddress!['city']}',
              shippingAddress!['country'],
            ]
              .where((e) => e != null && e.toString().isNotEmpty)
              .join(', ')
          : '',
      'items': items
          .map((item) => {
                'name': item.productName,
                'brand': item.productBrand,
                'image': item.productImage,
                'size': item.size,
                'quantity': item.quantity,
                'unitPrice': item.price / 100,
                'total': (item.price * item.quantity) / 100,
              })
          .toList(),
      'subtotal': totalPrice / 100,
      'discount': (discountAmount ?? 0) / 100,
      'discountCode': discountCodeId ?? '',
      'total': totalPrice / 100,
      'status': statusLabel,
    };
  }
}
