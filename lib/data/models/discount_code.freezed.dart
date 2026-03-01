// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discount_code.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DiscountCode {

 String get id; String get code; String? get description; String get discountType; int get discountValue; int get minPurchase; int? get maxUses; int get maxUsesPerUser; int get currentUses; bool get isActive;@JsonKey(fromJson: _nullableDateTimeFromJson) DateTime? get startsAt;@JsonKey(fromJson: _nullableDateTimeFromJson) DateTime? get expiresAt; String? get createdBy;@JsonKey(fromJson: _nullableDateTimeFromJson) DateTime? get createdAt;
/// Create a copy of DiscountCode
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscountCodeCopyWith<DiscountCode> get copyWith => _$DiscountCodeCopyWithImpl<DiscountCode>(this as DiscountCode, _$identity);

  /// Serializes this DiscountCode to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscountCode&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.discountValue, discountValue) || other.discountValue == discountValue)&&(identical(other.minPurchase, minPurchase) || other.minPurchase == minPurchase)&&(identical(other.maxUses, maxUses) || other.maxUses == maxUses)&&(identical(other.maxUsesPerUser, maxUsesPerUser) || other.maxUsesPerUser == maxUsesPerUser)&&(identical(other.currentUses, currentUses) || other.currentUses == currentUses)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,description,discountType,discountValue,minPurchase,maxUses,maxUsesPerUser,currentUses,isActive,startsAt,expiresAt,createdBy,createdAt);

@override
String toString() {
  return 'DiscountCode(id: $id, code: $code, description: $description, discountType: $discountType, discountValue: $discountValue, minPurchase: $minPurchase, maxUses: $maxUses, maxUsesPerUser: $maxUsesPerUser, currentUses: $currentUses, isActive: $isActive, startsAt: $startsAt, expiresAt: $expiresAt, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DiscountCodeCopyWith<$Res>  {
  factory $DiscountCodeCopyWith(DiscountCode value, $Res Function(DiscountCode) _then) = _$DiscountCodeCopyWithImpl;
@useResult
$Res call({
 String id, String code, String? description, String discountType, int discountValue, int minPurchase, int? maxUses, int maxUsesPerUser, int currentUses, bool isActive,@JsonKey(fromJson: _nullableDateTimeFromJson) DateTime? startsAt,@JsonKey(fromJson: _nullableDateTimeFromJson) DateTime? expiresAt, String? createdBy,@JsonKey(fromJson: _nullableDateTimeFromJson) DateTime? createdAt
});




}
/// @nodoc
class _$DiscountCodeCopyWithImpl<$Res>
    implements $DiscountCodeCopyWith<$Res> {
  _$DiscountCodeCopyWithImpl(this._self, this._then);

  final DiscountCode _self;
  final $Res Function(DiscountCode) _then;

/// Create a copy of DiscountCode
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? code = null,Object? description = freezed,Object? discountType = null,Object? discountValue = null,Object? minPurchase = null,Object? maxUses = freezed,Object? maxUsesPerUser = null,Object? currentUses = null,Object? isActive = null,Object? startsAt = freezed,Object? expiresAt = freezed,Object? createdBy = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,discountType: null == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as String,discountValue: null == discountValue ? _self.discountValue : discountValue // ignore: cast_nullable_to_non_nullable
as int,minPurchase: null == minPurchase ? _self.minPurchase : minPurchase // ignore: cast_nullable_to_non_nullable
as int,maxUses: freezed == maxUses ? _self.maxUses : maxUses // ignore: cast_nullable_to_non_nullable
as int?,maxUsesPerUser: null == maxUsesPerUser ? _self.maxUsesPerUser : maxUsesPerUser // ignore: cast_nullable_to_non_nullable
as int,currentUses: null == currentUses ? _self.currentUses : currentUses // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,startsAt: freezed == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DiscountCode].
extension DiscountCodePatterns on DiscountCode {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiscountCode value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiscountCode() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiscountCode value)  $default,){
final _that = this;
switch (_that) {
case _DiscountCode():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiscountCode value)?  $default,){
final _that = this;
switch (_that) {
case _DiscountCode() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String code,  String? description,  String discountType,  int discountValue,  int minPurchase,  int? maxUses,  int maxUsesPerUser,  int currentUses,  bool isActive, @JsonKey(fromJson: _nullableDateTimeFromJson)  DateTime? startsAt, @JsonKey(fromJson: _nullableDateTimeFromJson)  DateTime? expiresAt,  String? createdBy, @JsonKey(fromJson: _nullableDateTimeFromJson)  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiscountCode() when $default != null:
return $default(_that.id,_that.code,_that.description,_that.discountType,_that.discountValue,_that.minPurchase,_that.maxUses,_that.maxUsesPerUser,_that.currentUses,_that.isActive,_that.startsAt,_that.expiresAt,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String code,  String? description,  String discountType,  int discountValue,  int minPurchase,  int? maxUses,  int maxUsesPerUser,  int currentUses,  bool isActive, @JsonKey(fromJson: _nullableDateTimeFromJson)  DateTime? startsAt, @JsonKey(fromJson: _nullableDateTimeFromJson)  DateTime? expiresAt,  String? createdBy, @JsonKey(fromJson: _nullableDateTimeFromJson)  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _DiscountCode():
return $default(_that.id,_that.code,_that.description,_that.discountType,_that.discountValue,_that.minPurchase,_that.maxUses,_that.maxUsesPerUser,_that.currentUses,_that.isActive,_that.startsAt,_that.expiresAt,_that.createdBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String code,  String? description,  String discountType,  int discountValue,  int minPurchase,  int? maxUses,  int maxUsesPerUser,  int currentUses,  bool isActive, @JsonKey(fromJson: _nullableDateTimeFromJson)  DateTime? startsAt, @JsonKey(fromJson: _nullableDateTimeFromJson)  DateTime? expiresAt,  String? createdBy, @JsonKey(fromJson: _nullableDateTimeFromJson)  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DiscountCode() when $default != null:
return $default(_that.id,_that.code,_that.description,_that.discountType,_that.discountValue,_that.minPurchase,_that.maxUses,_that.maxUsesPerUser,_that.currentUses,_that.isActive,_that.startsAt,_that.expiresAt,_that.createdBy,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _DiscountCode implements DiscountCode {
  const _DiscountCode({required this.id, required this.code, this.description, this.discountType = 'percentage', required this.discountValue, this.minPurchase = 0, this.maxUses, this.maxUsesPerUser = 1, this.currentUses = 0, this.isActive = true, @JsonKey(fromJson: _nullableDateTimeFromJson) this.startsAt, @JsonKey(fromJson: _nullableDateTimeFromJson) this.expiresAt, this.createdBy, @JsonKey(fromJson: _nullableDateTimeFromJson) this.createdAt});
  factory _DiscountCode.fromJson(Map<String, dynamic> json) => _$DiscountCodeFromJson(json);

@override final  String id;
@override final  String code;
@override final  String? description;
@override@JsonKey() final  String discountType;
@override final  int discountValue;
@override@JsonKey() final  int minPurchase;
@override final  int? maxUses;
@override@JsonKey() final  int maxUsesPerUser;
@override@JsonKey() final  int currentUses;
@override@JsonKey() final  bool isActive;
@override@JsonKey(fromJson: _nullableDateTimeFromJson) final  DateTime? startsAt;
@override@JsonKey(fromJson: _nullableDateTimeFromJson) final  DateTime? expiresAt;
@override final  String? createdBy;
@override@JsonKey(fromJson: _nullableDateTimeFromJson) final  DateTime? createdAt;

/// Create a copy of DiscountCode
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiscountCodeCopyWith<_DiscountCode> get copyWith => __$DiscountCodeCopyWithImpl<_DiscountCode>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DiscountCodeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiscountCode&&(identical(other.id, id) || other.id == id)&&(identical(other.code, code) || other.code == code)&&(identical(other.description, description) || other.description == description)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.discountValue, discountValue) || other.discountValue == discountValue)&&(identical(other.minPurchase, minPurchase) || other.minPurchase == minPurchase)&&(identical(other.maxUses, maxUses) || other.maxUses == maxUses)&&(identical(other.maxUsesPerUser, maxUsesPerUser) || other.maxUsesPerUser == maxUsesPerUser)&&(identical(other.currentUses, currentUses) || other.currentUses == currentUses)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.startsAt, startsAt) || other.startsAt == startsAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,code,description,discountType,discountValue,minPurchase,maxUses,maxUsesPerUser,currentUses,isActive,startsAt,expiresAt,createdBy,createdAt);

@override
String toString() {
  return 'DiscountCode(id: $id, code: $code, description: $description, discountType: $discountType, discountValue: $discountValue, minPurchase: $minPurchase, maxUses: $maxUses, maxUsesPerUser: $maxUsesPerUser, currentUses: $currentUses, isActive: $isActive, startsAt: $startsAt, expiresAt: $expiresAt, createdBy: $createdBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DiscountCodeCopyWith<$Res> implements $DiscountCodeCopyWith<$Res> {
  factory _$DiscountCodeCopyWith(_DiscountCode value, $Res Function(_DiscountCode) _then) = __$DiscountCodeCopyWithImpl;
@override @useResult
$Res call({
 String id, String code, String? description, String discountType, int discountValue, int minPurchase, int? maxUses, int maxUsesPerUser, int currentUses, bool isActive,@JsonKey(fromJson: _nullableDateTimeFromJson) DateTime? startsAt,@JsonKey(fromJson: _nullableDateTimeFromJson) DateTime? expiresAt, String? createdBy,@JsonKey(fromJson: _nullableDateTimeFromJson) DateTime? createdAt
});




}
/// @nodoc
class __$DiscountCodeCopyWithImpl<$Res>
    implements _$DiscountCodeCopyWith<$Res> {
  __$DiscountCodeCopyWithImpl(this._self, this._then);

  final _DiscountCode _self;
  final $Res Function(_DiscountCode) _then;

/// Create a copy of DiscountCode
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? code = null,Object? description = freezed,Object? discountType = null,Object? discountValue = null,Object? minPurchase = null,Object? maxUses = freezed,Object? maxUsesPerUser = null,Object? currentUses = null,Object? isActive = null,Object? startsAt = freezed,Object? expiresAt = freezed,Object? createdBy = freezed,Object? createdAt = freezed,}) {
  return _then(_DiscountCode(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,discountType: null == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as String,discountValue: null == discountValue ? _self.discountValue : discountValue // ignore: cast_nullable_to_non_nullable
as int,minPurchase: null == minPurchase ? _self.minPurchase : minPurchase // ignore: cast_nullable_to_non_nullable
as int,maxUses: freezed == maxUses ? _self.maxUses : maxUses // ignore: cast_nullable_to_non_nullable
as int?,maxUsesPerUser: null == maxUsesPerUser ? _self.maxUsesPerUser : maxUsesPerUser // ignore: cast_nullable_to_non_nullable
as int,currentUses: null == currentUses ? _self.currentUses : currentUses // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,startsAt: freezed == startsAt ? _self.startsAt : startsAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
