import 'package:freezed_annotation/freezed_annotation.dart';
import 'product.dart';

part 'cart_item.freezed.dart';
part 'cart_item.g.dart';

@freezed
abstract class CartItem with _$CartItem {
  const CartItem._(); // Para getters computados

  @JsonSerializable(explicitToJson: true)
  const factory CartItem({
    required Product product,
    required int quantity,
    required String size,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  // ─── Convenience getters ──────────────────────────────────────────

  /// Shortcut to product.id – used widely in cart/order code.
  String get productId => product.id;

  /// Total price for this line item (cents, base without VAT)
  int get totalPrice => product.effectivePrice * quantity;

  /// Available stock for the selected size
  int get availableStock {
    final sizeData = product.sizesAvailable[size];
    if (sizeData is int) return sizeData;
    if (sizeData is Map) return (sizeData['stock'] as num?)?.toInt() ?? 0;
    return 0;
  }
}
