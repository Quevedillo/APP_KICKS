import 'dart:convert';

class OrderItem {
  final String productId;
  final String productName;
  final String productBrand;
  final String productImage;
  final int price;
  final String size;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productBrand,
    required this.productImage,
    required this.price,
    required this.size,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    final priceValue = json['price'] ?? product?['price'] ?? 0;
    final quantityValue = json['quantity'] ?? json['qty'] ?? 1;
    
    // Helper para convertir a int de forma segura
    int _safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      if (value is num) return value.toInt();
      return 0;
    }
    
    return OrderItem(
      productId: json['product_id'] ?? product?['id'] ?? '',
      productName: product?['name'] ?? json['name'] ?? '',
      productBrand: product?['brand'] ?? json['brand'] ?? '',
      productImage: (product?['images'] as List?)?.first ?? json['image'] ?? '',
      price: _safeInt(priceValue),
      size: json['size'] ?? '',
      quantity: _safeInt(quantityValue),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': productName,
      'brand': productBrand,
      'image': productImage,
      'price': price,
      'size': size,
      'quantity': quantity,
    };
  }
}

class Order {
  final String id;
  final String? stripeSessionId;
  final String? stripePaymentIntentId;
  final String userId;
  final int totalPrice;
  final int? subtotalAmount;
  final int? shippingAmount;
  final int? discountAmount;
  final String? discountCodeId;
  final String status;
  final String? returnStatus;
  final String? cancelledReason;
  final List<OrderItem> items;
  final String? shippingName;
  final String? shippingEmail;
  final String? shippingPhone;
  final Map<String, dynamic>? shippingAddress;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    this.stripeSessionId,
    this.stripePaymentIntentId,
    required this.userId,
    required this.totalPrice,
    this.subtotalAmount,
    this.shippingAmount,
    this.discountAmount,
    this.discountCodeId,
    required this.status,
    this.returnStatus,
    this.cancelledReason,
    required this.items,
    this.shippingName,
    this.shippingEmail,
    this.shippingPhone,
    this.shippingAddress,
    required this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> items = [];
    final itemsData = json['items'];
    
    if (itemsData != null) {
      if (itemsData is String) {
        // Si viene como string JSON, parsearlo
        try {
          final jsonDecoded = jsonDecode(itemsData);
          if (jsonDecoded is List) {
            items = jsonDecoded.map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList();
          }
        } catch (e) {
          print('Error parsing items from string: $e');
        }
      } else if (itemsData is List) {
        // Si ya es una lista, mapearla directamente
        try {
          items = itemsData.map((e) {
            if (e is Map<String, dynamic>) {
              return OrderItem.fromJson(e);
            } else if (e is String) {
              return OrderItem.fromJson(jsonDecode(e) as Map<String, dynamic>);
            }
            return null;
          }).whereType<OrderItem>().toList();
        } catch (e) {
          print('Error parsing items from list: $e');
        }
      }
    }
    
    return Order(
      id: json['id'] as String? ?? '',
      stripeSessionId: json['stripe_session_id'] as String?,
      stripePaymentIntentId: json['stripe_payment_intent_id'] as String?,
      userId: json['user_id'] as String? ?? '',
      totalPrice: _parseInt(json['total_amount'] ?? json['total_price']),
      subtotalAmount: _parseInt(json['subtotal_amount']),
      shippingAmount: _parseInt(json['shipping_amount']),
      discountAmount: _parseInt(json['discount_amount']),
      discountCodeId: json['discount_code_id'] as String?,
      status: json['status'] as String? ?? 'pending',
      returnStatus: json['return_status'] as String?,
      cancelledReason: json['cancelled_reason'] as String?,
      items: items,
      shippingName: json['shipping_name'] as String?,
      shippingEmail: (json['billing_email'] ?? json['shipping_email']) as String?,
      shippingPhone: json['shipping_phone'] as String?,
      shippingAddress: _parseShippingAddress(json['shipping_address']),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  static Map<String, dynamic>? _parseShippingAddress(dynamic address) {
    if (address == null) return null;
    if (address is Map<String, dynamic>) return address;
    if (address is String) {
      try {
        final decoded = jsonDecode(address);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (e) {
        print('Error parsing shipping_address: $e');
      }
    }
    return null;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    if (value is double) return value.toInt();
    return 0;
  }

  String get displayId {
    if (stripeSessionId != null && stripeSessionId!.length >= 8) {
      return stripeSessionId!.substring(stripeSessionId!.length - 8).toUpperCase();
    }
    return id.substring(0, 8).toUpperCase();
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
  bool get canRequestRefund => ['shipped', 'delivered'].contains(status) && returnStatus == null;

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
            ].where((e) => e != null && e.toString().isNotEmpty).join(', ')
          : '',
      'items': items.map((item) => {
        'name': item.productName,
        'brand': item.productBrand,
        'size': item.size,
        'quantity': item.quantity,
        'unitPrice': item.price / 100,
        'total': (item.price * item.quantity) / 100,
      }).toList(),
      'subtotal': totalPrice / 100,
      'discount': (discountAmount ?? 0) / 100,
      'discountCode': discountCodeId ?? '',
      'total': totalPrice / 100,
      'status': statusLabel,
    };
  }
}
