import 'package:freezed_annotation/freezed_annotation.dart';

part 'discount_code.freezed.dart';
part 'discount_code.g.dart';

DateTime? _nullableDateTimeFromJson(dynamic v) =>
    v is String ? DateTime.tryParse(v) : null;

@freezed
abstract class DiscountCode with _$DiscountCode {
  @JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
  const factory DiscountCode({
    required String id,
    required String code,
    String? description,
    @Default('percentage') String discountType,
    required int discountValue,
    @Default(0) int minPurchase,
    int? maxUses,
    @Default(1) int maxUsesPerUser,
    @Default(0) int currentUses,
    @Default(true) bool isActive,
    @JsonKey(fromJson: _nullableDateTimeFromJson) DateTime? startsAt,
    @JsonKey(fromJson: _nullableDateTimeFromJson) DateTime? expiresAt,
    String? createdBy,
    @JsonKey(fromJson: _nullableDateTimeFromJson) DateTime? createdAt,
  }) = _DiscountCode;

  factory DiscountCode.fromJson(Map<String, dynamic> json) =>
      _$DiscountCodeFromJson(json);
}
