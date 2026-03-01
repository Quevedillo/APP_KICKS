// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discount_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DiscountValidationResult {

 bool get valid; String? get error; DiscountCode? get discountCode; int? get discountAmount;
/// Create a copy of DiscountValidationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DiscountValidationResultCopyWith<DiscountValidationResult> get copyWith => _$DiscountValidationResultCopyWithImpl<DiscountValidationResult>(this as DiscountValidationResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DiscountValidationResult&&(identical(other.valid, valid) || other.valid == valid)&&(identical(other.error, error) || other.error == error)&&(identical(other.discountCode, discountCode) || other.discountCode == discountCode)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount));
}


@override
int get hashCode => Object.hash(runtimeType,valid,error,discountCode,discountAmount);

@override
String toString() {
  return 'DiscountValidationResult(valid: $valid, error: $error, discountCode: $discountCode, discountAmount: $discountAmount)';
}


}

/// @nodoc
abstract mixin class $DiscountValidationResultCopyWith<$Res>  {
  factory $DiscountValidationResultCopyWith(DiscountValidationResult value, $Res Function(DiscountValidationResult) _then) = _$DiscountValidationResultCopyWithImpl;
@useResult
$Res call({
 bool valid, String? error, DiscountCode? discountCode, int? discountAmount
});


$DiscountCodeCopyWith<$Res>? get discountCode;

}
/// @nodoc
class _$DiscountValidationResultCopyWithImpl<$Res>
    implements $DiscountValidationResultCopyWith<$Res> {
  _$DiscountValidationResultCopyWithImpl(this._self, this._then);

  final DiscountValidationResult _self;
  final $Res Function(DiscountValidationResult) _then;

/// Create a copy of DiscountValidationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? valid = null,Object? error = freezed,Object? discountCode = freezed,Object? discountAmount = freezed,}) {
  return _then(_self.copyWith(
valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,discountCode: freezed == discountCode ? _self.discountCode : discountCode // ignore: cast_nullable_to_non_nullable
as DiscountCode?,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of DiscountValidationResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiscountCodeCopyWith<$Res>? get discountCode {
    if (_self.discountCode == null) {
    return null;
  }

  return $DiscountCodeCopyWith<$Res>(_self.discountCode!, (value) {
    return _then(_self.copyWith(discountCode: value));
  });
}
}


/// Adds pattern-matching-related methods to [DiscountValidationResult].
extension DiscountValidationResultPatterns on DiscountValidationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DiscountValidationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DiscountValidationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DiscountValidationResult value)  $default,){
final _that = this;
switch (_that) {
case _DiscountValidationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DiscountValidationResult value)?  $default,){
final _that = this;
switch (_that) {
case _DiscountValidationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool valid,  String? error,  DiscountCode? discountCode,  int? discountAmount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DiscountValidationResult() when $default != null:
return $default(_that.valid,_that.error,_that.discountCode,_that.discountAmount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool valid,  String? error,  DiscountCode? discountCode,  int? discountAmount)  $default,) {final _that = this;
switch (_that) {
case _DiscountValidationResult():
return $default(_that.valid,_that.error,_that.discountCode,_that.discountAmount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool valid,  String? error,  DiscountCode? discountCode,  int? discountAmount)?  $default,) {final _that = this;
switch (_that) {
case _DiscountValidationResult() when $default != null:
return $default(_that.valid,_that.error,_that.discountCode,_that.discountAmount);case _:
  return null;

}
}

}

/// @nodoc


class _DiscountValidationResult implements DiscountValidationResult {
  const _DiscountValidationResult({required this.valid, this.error, this.discountCode, this.discountAmount});
  

@override final  bool valid;
@override final  String? error;
@override final  DiscountCode? discountCode;
@override final  int? discountAmount;

/// Create a copy of DiscountValidationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DiscountValidationResultCopyWith<_DiscountValidationResult> get copyWith => __$DiscountValidationResultCopyWithImpl<_DiscountValidationResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DiscountValidationResult&&(identical(other.valid, valid) || other.valid == valid)&&(identical(other.error, error) || other.error == error)&&(identical(other.discountCode, discountCode) || other.discountCode == discountCode)&&(identical(other.discountAmount, discountAmount) || other.discountAmount == discountAmount));
}


@override
int get hashCode => Object.hash(runtimeType,valid,error,discountCode,discountAmount);

@override
String toString() {
  return 'DiscountValidationResult(valid: $valid, error: $error, discountCode: $discountCode, discountAmount: $discountAmount)';
}


}

/// @nodoc
abstract mixin class _$DiscountValidationResultCopyWith<$Res> implements $DiscountValidationResultCopyWith<$Res> {
  factory _$DiscountValidationResultCopyWith(_DiscountValidationResult value, $Res Function(_DiscountValidationResult) _then) = __$DiscountValidationResultCopyWithImpl;
@override @useResult
$Res call({
 bool valid, String? error, DiscountCode? discountCode, int? discountAmount
});


@override $DiscountCodeCopyWith<$Res>? get discountCode;

}
/// @nodoc
class __$DiscountValidationResultCopyWithImpl<$Res>
    implements _$DiscountValidationResultCopyWith<$Res> {
  __$DiscountValidationResultCopyWithImpl(this._self, this._then);

  final _DiscountValidationResult _self;
  final $Res Function(_DiscountValidationResult) _then;

/// Create a copy of DiscountValidationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? valid = null,Object? error = freezed,Object? discountCode = freezed,Object? discountAmount = freezed,}) {
  return _then(_DiscountValidationResult(
valid: null == valid ? _self.valid : valid // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,discountCode: freezed == discountCode ? _self.discountCode : discountCode // ignore: cast_nullable_to_non_nullable
as DiscountCode?,discountAmount: freezed == discountAmount ? _self.discountAmount : discountAmount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of DiscountValidationResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DiscountCodeCopyWith<$Res>? get discountCode {
    if (_self.discountCode == null) {
    return null;
  }

  return $DiscountCodeCopyWith<$Res>(_self.discountCode!, (value) {
    return _then(_self.copyWith(discountCode: value));
  });
}
}

// dart format on
