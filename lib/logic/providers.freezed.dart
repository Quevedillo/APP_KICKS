// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'providers.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductFilter {

 String? get brand; String? get categoryId; String? get color; int? get minPriceCents; int? get maxPriceCents; String get sortBy; String? get searchQuery;
/// Create a copy of ProductFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductFilterCopyWith<ProductFilter> get copyWith => _$ProductFilterCopyWithImpl<ProductFilter>(this as ProductFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductFilter&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.color, color) || other.color == color)&&(identical(other.minPriceCents, minPriceCents) || other.minPriceCents == minPriceCents)&&(identical(other.maxPriceCents, maxPriceCents) || other.maxPriceCents == maxPriceCents)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,brand,categoryId,color,minPriceCents,maxPriceCents,sortBy,searchQuery);

@override
String toString() {
  return 'ProductFilter(brand: $brand, categoryId: $categoryId, color: $color, minPriceCents: $minPriceCents, maxPriceCents: $maxPriceCents, sortBy: $sortBy, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class $ProductFilterCopyWith<$Res>  {
  factory $ProductFilterCopyWith(ProductFilter value, $Res Function(ProductFilter) _then) = _$ProductFilterCopyWithImpl;
@useResult
$Res call({
 String? brand, String? categoryId, String? color, int? minPriceCents, int? maxPriceCents, String sortBy, String? searchQuery
});




}
/// @nodoc
class _$ProductFilterCopyWithImpl<$Res>
    implements $ProductFilterCopyWith<$Res> {
  _$ProductFilterCopyWithImpl(this._self, this._then);

  final ProductFilter _self;
  final $Res Function(ProductFilter) _then;

/// Create a copy of ProductFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? brand = freezed,Object? categoryId = freezed,Object? color = freezed,Object? minPriceCents = freezed,Object? maxPriceCents = freezed,Object? sortBy = null,Object? searchQuery = freezed,}) {
  return _then(_self.copyWith(
brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,minPriceCents: freezed == minPriceCents ? _self.minPriceCents : minPriceCents // ignore: cast_nullable_to_non_nullable
as int?,maxPriceCents: freezed == maxPriceCents ? _self.maxPriceCents : maxPriceCents // ignore: cast_nullable_to_non_nullable
as int?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductFilter].
extension ProductFilterPatterns on ProductFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductFilter value)  $default,){
final _that = this;
switch (_that) {
case _ProductFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ProductFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? brand,  String? categoryId,  String? color,  int? minPriceCents,  int? maxPriceCents,  String sortBy,  String? searchQuery)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductFilter() when $default != null:
return $default(_that.brand,_that.categoryId,_that.color,_that.minPriceCents,_that.maxPriceCents,_that.sortBy,_that.searchQuery);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? brand,  String? categoryId,  String? color,  int? minPriceCents,  int? maxPriceCents,  String sortBy,  String? searchQuery)  $default,) {final _that = this;
switch (_that) {
case _ProductFilter():
return $default(_that.brand,_that.categoryId,_that.color,_that.minPriceCents,_that.maxPriceCents,_that.sortBy,_that.searchQuery);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? brand,  String? categoryId,  String? color,  int? minPriceCents,  int? maxPriceCents,  String sortBy,  String? searchQuery)?  $default,) {final _that = this;
switch (_that) {
case _ProductFilter() when $default != null:
return $default(_that.brand,_that.categoryId,_that.color,_that.minPriceCents,_that.maxPriceCents,_that.sortBy,_that.searchQuery);case _:
  return null;

}
}

}

/// @nodoc


class _ProductFilter implements ProductFilter {
  const _ProductFilter({this.brand, this.categoryId, this.color, this.minPriceCents, this.maxPriceCents, this.sortBy = 'newest', this.searchQuery});
  

@override final  String? brand;
@override final  String? categoryId;
@override final  String? color;
@override final  int? minPriceCents;
@override final  int? maxPriceCents;
@override@JsonKey() final  String sortBy;
@override final  String? searchQuery;

/// Create a copy of ProductFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductFilterCopyWith<_ProductFilter> get copyWith => __$ProductFilterCopyWithImpl<_ProductFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductFilter&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.color, color) || other.color == color)&&(identical(other.minPriceCents, minPriceCents) || other.minPriceCents == minPriceCents)&&(identical(other.maxPriceCents, maxPriceCents) || other.maxPriceCents == maxPriceCents)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,brand,categoryId,color,minPriceCents,maxPriceCents,sortBy,searchQuery);

@override
String toString() {
  return 'ProductFilter(brand: $brand, categoryId: $categoryId, color: $color, minPriceCents: $minPriceCents, maxPriceCents: $maxPriceCents, sortBy: $sortBy, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class _$ProductFilterCopyWith<$Res> implements $ProductFilterCopyWith<$Res> {
  factory _$ProductFilterCopyWith(_ProductFilter value, $Res Function(_ProductFilter) _then) = __$ProductFilterCopyWithImpl;
@override @useResult
$Res call({
 String? brand, String? categoryId, String? color, int? minPriceCents, int? maxPriceCents, String sortBy, String? searchQuery
});




}
/// @nodoc
class __$ProductFilterCopyWithImpl<$Res>
    implements _$ProductFilterCopyWith<$Res> {
  __$ProductFilterCopyWithImpl(this._self, this._then);

  final _ProductFilter _self;
  final $Res Function(_ProductFilter) _then;

/// Create a copy of ProductFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? brand = freezed,Object? categoryId = freezed,Object? color = freezed,Object? minPriceCents = freezed,Object? maxPriceCents = freezed,Object? sortBy = null,Object? searchQuery = freezed,}) {
  return _then(_ProductFilter(
brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,minPriceCents: freezed == minPriceCents ? _self.minPriceCents : minPriceCents // ignore: cast_nullable_to_non_nullable
as int?,maxPriceCents: freezed == maxPriceCents ? _self.maxPriceCents : maxPriceCents // ignore: cast_nullable_to_non_nullable
as int?,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,searchQuery: freezed == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
