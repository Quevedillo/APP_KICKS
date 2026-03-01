// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OrderItem {

 String get productId; String get productName; String get productBrand; String get productImage; int get price; String get size; int get quantity;
/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderItemCopyWith<OrderItem> get copyWith => _$OrderItemCopyWithImpl<OrderItem>(this as OrderItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OrderItem&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productBrand, productBrand) || other.productBrand == productBrand)&&(identical(other.productImage, productImage) || other.productImage == productImage)&&(identical(other.price, price) || other.price == price)&&(identical(other.size, size) || other.size == size)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}


@override
int get hashCode => Object.hash(runtimeType,productId,productName,productBrand,productImage,price,size,quantity);

@override
String toString() {
  return 'OrderItem(productId: $productId, productName: $productName, productBrand: $productBrand, productImage: $productImage, price: $price, size: $size, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $OrderItemCopyWith<$Res>  {
  factory $OrderItemCopyWith(OrderItem value, $Res Function(OrderItem) _then) = _$OrderItemCopyWithImpl;
@useResult
$Res call({
 String productId, String productName, String productBrand, String productImage, int price, String size, int quantity
});




}
/// @nodoc
class _$OrderItemCopyWithImpl<$Res>
    implements $OrderItemCopyWith<$Res> {
  _$OrderItemCopyWithImpl(this._self, this._then);

  final OrderItem _self;
  final $Res Function(OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? productId = null,Object? productName = null,Object? productBrand = null,Object? productImage = null,Object? price = null,Object? size = null,Object? quantity = null,}) {
  return _then(_self.copyWith(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,productBrand: null == productBrand ? _self.productBrand : productBrand // ignore: cast_nullable_to_non_nullable
as String,productImage: null == productImage ? _self.productImage : productImage // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OrderItem].
extension OrderItemPatterns on OrderItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OrderItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OrderItem value)  $default,){
final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OrderItem value)?  $default,){
final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String productId,  String productName,  String productBrand,  String productImage,  int price,  String size,  int quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.productId,_that.productName,_that.productBrand,_that.productImage,_that.price,_that.size,_that.quantity);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String productId,  String productName,  String productBrand,  String productImage,  int price,  String size,  int quantity)  $default,) {final _that = this;
switch (_that) {
case _OrderItem():
return $default(_that.productId,_that.productName,_that.productBrand,_that.productImage,_that.price,_that.size,_that.quantity);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String productId,  String productName,  String productBrand,  String productImage,  int price,  String size,  int quantity)?  $default,) {final _that = this;
switch (_that) {
case _OrderItem() when $default != null:
return $default(_that.productId,_that.productName,_that.productBrand,_that.productImage,_that.price,_that.size,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc


class _OrderItem implements OrderItem {
  const _OrderItem({required this.productId, required this.productName, this.productBrand = '', this.productImage = '', required this.price, required this.size, this.quantity = 1});
  

@override final  String productId;
@override final  String productName;
@override@JsonKey() final  String productBrand;
@override@JsonKey() final  String productImage;
@override final  int price;
@override final  String size;
@override@JsonKey() final  int quantity;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderItemCopyWith<_OrderItem> get copyWith => __$OrderItemCopyWithImpl<_OrderItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OrderItem&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.productBrand, productBrand) || other.productBrand == productBrand)&&(identical(other.productImage, productImage) || other.productImage == productImage)&&(identical(other.price, price) || other.price == price)&&(identical(other.size, size) || other.size == size)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}


@override
int get hashCode => Object.hash(runtimeType,productId,productName,productBrand,productImage,price,size,quantity);

@override
String toString() {
  return 'OrderItem(productId: $productId, productName: $productName, productBrand: $productBrand, productImage: $productImage, price: $price, size: $size, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$OrderItemCopyWith<$Res> implements $OrderItemCopyWith<$Res> {
  factory _$OrderItemCopyWith(_OrderItem value, $Res Function(_OrderItem) _then) = __$OrderItemCopyWithImpl;
@override @useResult
$Res call({
 String productId, String productName, String productBrand, String productImage, int price, String size, int quantity
});




}
/// @nodoc
class __$OrderItemCopyWithImpl<$Res>
    implements _$OrderItemCopyWith<$Res> {
  __$OrderItemCopyWithImpl(this._self, this._then);

  final _OrderItem _self;
  final $Res Function(_OrderItem) _then;

/// Create a copy of OrderItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? productId = null,Object? productName = null,Object? productBrand = null,Object? productImage = null,Object? price = null,Object? size = null,Object? quantity = null,}) {
  return _then(_OrderItem(
productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,productBrand: null == productBrand ? _self.productBrand : productBrand // ignore: cast_nullable_to_non_nullable
as String,productImage: null == productImage ? _self.productImage : productImage // ignore: cast_nullable_to_non_nullable
as String,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$Order {

 String get id; String? get stripeSessionId; String? get stripePaymentIntentId; String get userId; int get totalPrice; int? get subtotalAmount; int? get shippingAmount; int? get discountAmount; String? get discountCodeId; String get status; String? get returnStatus; String? get cancelledReason; List<OrderItem> get items; String? get shippingName; String? get shippingEmail; String? get shippingPhone; Map<String, dynamic>? get shippingAddress; DateTime get createdAt; DateTime? get updatedAt;
/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OrderCopyWith<Order> get copyWith => _$OrderCopyWithImpl<Order>(this as Order, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Order&&(identical(other.id, id) || other.id == id)&&(identical(other.stripeSessionId, stripeSessionId) || other.stripeSessionId == stripeSessionId)&&(identical(other.stripePaymentIntentId, stripePaymentIntentId) || other.stripePaymentIntentId == stripePaymentIntentId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.subtotalAmount, subtotalAmount) || other.subtotalAmount == subtotalAmount)&&(identical(other.shippingAmount, shippingAmount) || other.shippingAmount == shippingAmount)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.discountCodeId, discountCodeId) || other.discountCodeId == discountCodeId)&&(identical(other.status, status) || other.status == status)&&(identical(other.returnStatus, returnStatus) || other.returnStatus == returnStatus)&&(identical(other.cancelledReason, cancelledReason) || other.cancelledReason == cancelledReason)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.shippingName, shippingName) || other.shippingName == shippingName)&&(identical(other.shippingEmail, shippingEmail) || other.shippingEmail == shippingEmail)&&(identical(other.shippingPhone, shippingPhone) || other.shippingPhone == shippingPhone)&&const DeepCollectionEquality().equals(other.shippingAddress, shippingAddress)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,stripeSessionId,stripePaymentIntentId,userId,totalPrice,subtotalAmount,shippingAmount,discountAmount,discountCodeId,status,returnStatus,cancelledReason,const DeepCollectionEquality().hash(items),shippingName,shippingEmail,shippingPhone,const DeepCollectionEquality().hash(shippingAddress),createdAt,updatedAt]);

@override
String toString() {
  return 'Order(id: $id, stripeSessionId: $stripeSessionId, stripePaymentIntentId: $stripePaymentIntentId, userId: $userId, totalPrice: $totalPrice, subtotalAmount: $subtotalAmount, shippingAmount: $shippingAmount, discountAmount: $discountAmount, discountCodeId: $discountCodeId, status: $status, returnStatus: $returnStatus, cancelledReason: $cancelledReason, items: $items, shippingName: $shippingName, shippingEmail: $shippingEmail, shippingPhone: $shippingPhone, shippingAddress: $shippingAddress, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $OrderCopyWith<$Res>  {
  factory $OrderCopyWith(Order value, $Res Function(Order) _then) = _$OrderCopyWithImpl;
@useResult
$Res call({
 String id, String? stripeSessionId, String? stripePaymentIntentId, String userId, int totalPrice, int? subtotalAmount, int? shippingAmount, int? discountAmount, String? discountCodeId, String status, String? returnStatus, String? cancelledReason, List<OrderItem> items, String? shippingName, String? shippingEmail, String? shippingPhone, Map<String, dynamic>? shippingAddress, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$OrderCopyWithImpl<$Res>
    implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._self, this._then);

  final Order _self;
  final $Res Function(Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? stripeSessionId = freezed,Object? stripePaymentIntentId = freezed,Object? userId = null,Object? totalPrice = null,Object? subtotalAmount = freezed,Object? shippingAmount = freezed,Object? discountAmount = freezed,Object? discountCodeId = freezed,Object? status = null,Object? returnStatus = freezed,Object? cancelledReason = freezed,Object? items = null,Object? shippingName = freezed,Object? shippingEmail = freezed,Object? shippingPhone = freezed,Object? shippingAddress = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,stripeSessionId: freezed == stripeSessionId ? _self.stripeSessionId : stripeSessionId // ignore: cast_nullable_to_non_nullable
as String?,stripePaymentIntentId: freezed == stripePaymentIntentId ? _self.stripePaymentIntentId : stripePaymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as int,subtotalAmount: freezed == subtotalAmount ? _self.subtotalAmount : subtotalAmount // ignore: cast_nullable_to_non_nullable
as int?,shippingAmount: freezed == shippingAmount ? _self.shippingAmount : shippingAmount // ignore: cast_nullable_to_non_nullable
as int?,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as int?,discountCodeId: freezed == discountCodeId ? _self.discountCodeId : discountCodeId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,returnStatus: freezed == returnStatus ? _self.returnStatus : returnStatus // ignore: cast_nullable_to_non_nullable
as String?,cancelledReason: freezed == cancelledReason ? _self.cancelledReason : cancelledReason // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,shippingName: freezed == shippingName ? _self.shippingName : shippingName // ignore: cast_nullable_to_non_nullable
as String?,shippingEmail: freezed == shippingEmail ? _self.shippingEmail : shippingEmail // ignore: cast_nullable_to_non_nullable
as String?,shippingPhone: freezed == shippingPhone ? _self.shippingPhone : shippingPhone // ignore: cast_nullable_to_non_nullable
as String?,shippingAddress: freezed == shippingAddress ? _self.shippingAddress : shippingAddress // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Order].
extension OrderPatterns on Order {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Order value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Order value)  $default,){
final _that = this;
switch (_that) {
case _Order():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Order value)?  $default,){
final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? stripeSessionId,  String? stripePaymentIntentId,  String userId,  int totalPrice,  int? subtotalAmount,  int? shippingAmount,  int? discountAmount,  String? discountCodeId,  String status,  String? returnStatus,  String? cancelledReason,  List<OrderItem> items,  String? shippingName,  String? shippingEmail,  String? shippingPhone,  Map<String, dynamic>? shippingAddress,  DateTime createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.stripeSessionId,_that.stripePaymentIntentId,_that.userId,_that.totalPrice,_that.subtotalAmount,_that.shippingAmount,_that.discountAmount,_that.discountCodeId,_that.status,_that.returnStatus,_that.cancelledReason,_that.items,_that.shippingName,_that.shippingEmail,_that.shippingPhone,_that.shippingAddress,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? stripeSessionId,  String? stripePaymentIntentId,  String userId,  int totalPrice,  int? subtotalAmount,  int? shippingAmount,  int? discountAmount,  String? discountCodeId,  String status,  String? returnStatus,  String? cancelledReason,  List<OrderItem> items,  String? shippingName,  String? shippingEmail,  String? shippingPhone,  Map<String, dynamic>? shippingAddress,  DateTime createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Order():
return $default(_that.id,_that.stripeSessionId,_that.stripePaymentIntentId,_that.userId,_that.totalPrice,_that.subtotalAmount,_that.shippingAmount,_that.discountAmount,_that.discountCodeId,_that.status,_that.returnStatus,_that.cancelledReason,_that.items,_that.shippingName,_that.shippingEmail,_that.shippingPhone,_that.shippingAddress,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? stripeSessionId,  String? stripePaymentIntentId,  String userId,  int totalPrice,  int? subtotalAmount,  int? shippingAmount,  int? discountAmount,  String? discountCodeId,  String status,  String? returnStatus,  String? cancelledReason,  List<OrderItem> items,  String? shippingName,  String? shippingEmail,  String? shippingPhone,  Map<String, dynamic>? shippingAddress,  DateTime createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Order() when $default != null:
return $default(_that.id,_that.stripeSessionId,_that.stripePaymentIntentId,_that.userId,_that.totalPrice,_that.subtotalAmount,_that.shippingAmount,_that.discountAmount,_that.discountCodeId,_that.status,_that.returnStatus,_that.cancelledReason,_that.items,_that.shippingName,_that.shippingEmail,_that.shippingPhone,_that.shippingAddress,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Order extends Order {
  const _Order({required this.id, this.stripeSessionId, this.stripePaymentIntentId, this.userId = '', required this.totalPrice, this.subtotalAmount, this.shippingAmount, this.discountAmount, this.discountCodeId, this.status = 'pending', this.returnStatus, this.cancelledReason, final  List<OrderItem> items = const [], this.shippingName, this.shippingEmail, this.shippingPhone, final  Map<String, dynamic>? shippingAddress, required this.createdAt, this.updatedAt}): _items = items,_shippingAddress = shippingAddress,super._();
  

@override final  String id;
@override final  String? stripeSessionId;
@override final  String? stripePaymentIntentId;
@override@JsonKey() final  String userId;
@override final  int totalPrice;
@override final  int? subtotalAmount;
@override final  int? shippingAmount;
@override final  int? discountAmount;
@override final  String? discountCodeId;
@override@JsonKey() final  String status;
@override final  String? returnStatus;
@override final  String? cancelledReason;
 final  List<OrderItem> _items;
@override@JsonKey() List<OrderItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  String? shippingName;
@override final  String? shippingEmail;
@override final  String? shippingPhone;
 final  Map<String, dynamic>? _shippingAddress;
@override Map<String, dynamic>? get shippingAddress {
  final value = _shippingAddress;
  if (value == null) return null;
  if (_shippingAddress is EqualUnmodifiableMapView) return _shippingAddress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  DateTime createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OrderCopyWith<_Order> get copyWith => __$OrderCopyWithImpl<_Order>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Order&&(identical(other.id, id) || other.id == id)&&(identical(other.stripeSessionId, stripeSessionId) || other.stripeSessionId == stripeSessionId)&&(identical(other.stripePaymentIntentId, stripePaymentIntentId) || other.stripePaymentIntentId == stripePaymentIntentId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.subtotalAmount, subtotalAmount) || other.subtotalAmount == subtotalAmount)&&(identical(other.shippingAmount, shippingAmount) || other.shippingAmount == shippingAmount)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount)&&(identical(other.discountCodeId, discountCodeId) || other.discountCodeId == discountCodeId)&&(identical(other.status, status) || other.status == status)&&(identical(other.returnStatus, returnStatus) || other.returnStatus == returnStatus)&&(identical(other.cancelledReason, cancelledReason) || other.cancelledReason == cancelledReason)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.shippingName, shippingName) || other.shippingName == shippingName)&&(identical(other.shippingEmail, shippingEmail) || other.shippingEmail == shippingEmail)&&(identical(other.shippingPhone, shippingPhone) || other.shippingPhone == shippingPhone)&&const DeepCollectionEquality().equals(other._shippingAddress, _shippingAddress)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}


@override
int get hashCode => Object.hashAll([runtimeType,id,stripeSessionId,stripePaymentIntentId,userId,totalPrice,subtotalAmount,shippingAmount,discountAmount,discountCodeId,status,returnStatus,cancelledReason,const DeepCollectionEquality().hash(_items),shippingName,shippingEmail,shippingPhone,const DeepCollectionEquality().hash(_shippingAddress),createdAt,updatedAt]);

@override
String toString() {
  return 'Order(id: $id, stripeSessionId: $stripeSessionId, stripePaymentIntentId: $stripePaymentIntentId, userId: $userId, totalPrice: $totalPrice, subtotalAmount: $subtotalAmount, shippingAmount: $shippingAmount, discountAmount: $discountAmount, discountCodeId: $discountCodeId, status: $status, returnStatus: $returnStatus, cancelledReason: $cancelledReason, items: $items, shippingName: $shippingName, shippingEmail: $shippingEmail, shippingPhone: $shippingPhone, shippingAddress: $shippingAddress, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) _then) = __$OrderCopyWithImpl;
@override @useResult
$Res call({
 String id, String? stripeSessionId, String? stripePaymentIntentId, String userId, int totalPrice, int? subtotalAmount, int? shippingAmount, int? discountAmount, String? discountCodeId, String status, String? returnStatus, String? cancelledReason, List<OrderItem> items, String? shippingName, String? shippingEmail, String? shippingPhone, Map<String, dynamic>? shippingAddress, DateTime createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(this._self, this._then);

  final _Order _self;
  final $Res Function(_Order) _then;

/// Create a copy of Order
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? stripeSessionId = freezed,Object? stripePaymentIntentId = freezed,Object? userId = null,Object? totalPrice = null,Object? subtotalAmount = freezed,Object? shippingAmount = freezed,Object? discountAmount = freezed,Object? discountCodeId = freezed,Object? status = null,Object? returnStatus = freezed,Object? cancelledReason = freezed,Object? items = null,Object? shippingName = freezed,Object? shippingEmail = freezed,Object? shippingPhone = freezed,Object? shippingAddress = freezed,Object? createdAt = null,Object? updatedAt = freezed,}) {
  return _then(_Order(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,stripeSessionId: freezed == stripeSessionId ? _self.stripeSessionId : stripeSessionId // ignore: cast_nullable_to_non_nullable
as String?,stripePaymentIntentId: freezed == stripePaymentIntentId ? _self.stripePaymentIntentId : stripePaymentIntentId // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as int,subtotalAmount: freezed == subtotalAmount ? _self.subtotalAmount : subtotalAmount // ignore: cast_nullable_to_non_nullable
as int?,shippingAmount: freezed == shippingAmount ? _self.shippingAmount : shippingAmount // ignore: cast_nullable_to_non_nullable
as int?,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as int?,discountCodeId: freezed == discountCodeId ? _self.discountCodeId : discountCodeId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,returnStatus: freezed == returnStatus ? _self.returnStatus : returnStatus // ignore: cast_nullable_to_non_nullable
as String?,cancelledReason: freezed == cancelledReason ? _self.cancelledReason : cancelledReason // ignore: cast_nullable_to_non_nullable
as String?,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<OrderItem>,shippingName: freezed == shippingName ? _self.shippingName : shippingName // ignore: cast_nullable_to_non_nullable
as String?,shippingEmail: freezed == shippingEmail ? _self.shippingEmail : shippingEmail // ignore: cast_nullable_to_non_nullable
as String?,shippingPhone: freezed == shippingPhone ? _self.shippingPhone : shippingPhone // ignore: cast_nullable_to_non_nullable
as String?,shippingAddress: freezed == shippingAddress ? _self._shippingAddress : shippingAddress // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
