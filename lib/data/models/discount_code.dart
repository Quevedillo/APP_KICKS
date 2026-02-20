class DiscountCode {
  final String id;
  final String code;
  final String? description;
  final String discountType; // 'percentage' or 'fixed'
  final int discountValue;
  final int minPurchase;
  final int? maxUses;
  final int maxUsesPerUser;
  final int currentUses;
  final bool isActive;
  final DateTime? expiresAt;

  DiscountCode({
    required this.id,
    required this.code,
    this.description,
    required this.discountType,
    required this.discountValue,
    required this.minPurchase,
    this.maxUses,
    required this.maxUsesPerUser,
    required this.currentUses,
    required this.isActive,
    this.expiresAt,
  });

  factory DiscountCode.fromJson(Map<String, dynamic> json) {
    return DiscountCode(
      id: json['id'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      discountType: json['discount_type'] as String,
      discountValue: (json['discount_value'] as num).toInt(),
      minPurchase: ((json['min_purchase'] as num?) ?? 0).toInt(),
      maxUses: (json['max_uses'] as num?)?.toInt(),
      maxUsesPerUser: ((json['max_uses_per_user'] as num?) ?? 1).toInt(),
      currentUses: ((json['current_uses'] as num?) ?? 0).toInt(),
      isActive: json['is_active'] as bool? ?? true,
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'description': description,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_purchase': minPurchase,
      'max_uses': maxUses,
      'max_uses_per_user': maxUsesPerUser,
      'is_active': isActive,
      'expires_at': expiresAt?.toIso8601String(),
    };
  }
}
