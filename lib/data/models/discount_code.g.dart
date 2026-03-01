// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discount_code.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DiscountCode _$DiscountCodeFromJson(Map<String, dynamic> json) =>
    _DiscountCode(
      id: json['id'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      discountType: json['discount_type'] as String? ?? 'percentage',
      discountValue: (json['discount_value'] as num).toInt(),
      minPurchase: (json['min_purchase'] as num?)?.toInt() ?? 0,
      maxUses: (json['max_uses'] as num?)?.toInt(),
      maxUsesPerUser: (json['max_uses_per_user'] as num?)?.toInt() ?? 1,
      currentUses: (json['current_uses'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      startsAt: _nullableDateTimeFromJson(json['starts_at']),
      expiresAt: _nullableDateTimeFromJson(json['expires_at']),
      createdBy: json['created_by'] as String?,
      createdAt: _nullableDateTimeFromJson(json['created_at']),
    );

Map<String, dynamic> _$DiscountCodeToJson(_DiscountCode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'description': instance.description,
      'discount_type': instance.discountType,
      'discount_value': instance.discountValue,
      'min_purchase': instance.minPurchase,
      'max_uses': instance.maxUses,
      'max_uses_per_user': instance.maxUsesPerUser,
      'current_uses': instance.currentUses,
      'is_active': instance.isActive,
      'starts_at': instance.startsAt?.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
      'created_by': instance.createdBy,
      'created_at': instance.createdAt?.toIso8601String(),
    };
