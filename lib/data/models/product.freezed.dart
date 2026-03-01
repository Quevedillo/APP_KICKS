// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'product.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Product {

 String get id; String get name; String get slug; String? get description; Map<String, dynamic>? get detailedDescription; int get price; int? get comparePrice; int? get costPrice;@JsonKey(fromJson: _intFromJson) int get stock; String? get categoryId; String? get brand;@JsonKey(name: 'model') String? get productModel; String? get colorway; String? get sku; bool get isLimitedEdition; bool get isFeatured; bool get isActive;@JsonKey(fromJson: _sizesFromJson) Map<String, dynamic> get sizesAvailable;@JsonKey(fromJson: _stringListFromJson) List<String> get images;@JsonKey(fromJson: _stringListFromJson) List<String> get tags;@JsonKey(fromJson: _dateTimeFromJson) DateTime get createdAt; String? get discountType; double? get discountValue; String? get releaseType; String? get releaseDate;
/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductCopyWith<Product> get copyWith => _$ProductCopyWithImpl<Product>(this as Product, _$identity);

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.detailedDescription, detailedDescription)&&(identical(other.price, price) || other.price == price)&&(identical(other.comparePrice, comparePrice) || other.comparePrice == comparePrice)&&(identical(other.costPrice, costPrice) || other.costPrice == costPrice)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.productModel, productModel) || other.productModel == productModel)&&(identical(other.colorway, colorway) || other.colorway == colorway)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.isLimitedEdition, isLimitedEdition) || other.isLimitedEdition == isLimitedEdition)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other.sizesAvailable, sizesAvailable)&&const DeepCollectionEquality().equals(other.images, images)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.discountValue, discountValue) || other.discountValue == discountValue)&&(identical(other.releaseType, releaseType) || other.releaseType == releaseType)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,slug,description,const DeepCollectionEquality().hash(detailedDescription),price,comparePrice,costPrice,stock,categoryId,brand,productModel,colorway,sku,isLimitedEdition,isFeatured,isActive,const DeepCollectionEquality().hash(sizesAvailable),const DeepCollectionEquality().hash(images),const DeepCollectionEquality().hash(tags),createdAt,discountType,discountValue,releaseType,releaseDate]);

@override
String toString() {
  return 'Product(id: $id, name: $name, slug: $slug, description: $description, detailedDescription: $detailedDescription, price: $price, comparePrice: $comparePrice, costPrice: $costPrice, stock: $stock, categoryId: $categoryId, brand: $brand, productModel: $productModel, colorway: $colorway, sku: $sku, isLimitedEdition: $isLimitedEdition, isFeatured: $isFeatured, isActive: $isActive, sizesAvailable: $sizesAvailable, images: $images, tags: $tags, createdAt: $createdAt, discountType: $discountType, discountValue: $discountValue, releaseType: $releaseType, releaseDate: $releaseDate)';
}


}

/// @nodoc
abstract mixin class $ProductCopyWith<$Res>  {
  factory $ProductCopyWith(Product value, $Res Function(Product) _then) = _$ProductCopyWithImpl;
@useResult
$Res call({
 String id, String name, String slug, String? description, Map<String, dynamic>? detailedDescription, int price, int? comparePrice, int? costPrice,@JsonKey(fromJson: _intFromJson) int stock, String? categoryId, String? brand,@JsonKey(name: 'model') String? productModel, String? colorway, String? sku, bool isLimitedEdition, bool isFeatured, bool isActive,@JsonKey(fromJson: _sizesFromJson) Map<String, dynamic> sizesAvailable,@JsonKey(fromJson: _stringListFromJson) List<String> images,@JsonKey(fromJson: _stringListFromJson) List<String> tags,@JsonKey(fromJson: _dateTimeFromJson) DateTime createdAt, String? discountType, double? discountValue, String? releaseType, String? releaseDate
});




}
/// @nodoc
class _$ProductCopyWithImpl<$Res>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._self, this._then);

  final Product _self;
  final $Res Function(Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? description = freezed,Object? detailedDescription = freezed,Object? price = null,Object? comparePrice = freezed,Object? costPrice = freezed,Object? stock = null,Object? categoryId = freezed,Object? brand = freezed,Object? productModel = freezed,Object? colorway = freezed,Object? sku = freezed,Object? isLimitedEdition = null,Object? isFeatured = null,Object? isActive = null,Object? sizesAvailable = null,Object? images = null,Object? tags = null,Object? createdAt = null,Object? discountType = freezed,Object? discountValue = freezed,Object? releaseType = freezed,Object? releaseDate = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,detailedDescription: freezed == detailedDescription ? _self.detailedDescription : detailedDescription // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,comparePrice: freezed == comparePrice ? _self.comparePrice : comparePrice // ignore: cast_nullable_to_non_nullable
as int?,costPrice: freezed == costPrice ? _self.costPrice : costPrice // ignore: cast_nullable_to_non_nullable
as int?,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,productModel: freezed == productModel ? _self.productModel : productModel // ignore: cast_nullable_to_non_nullable
as String?,colorway: freezed == colorway ? _self.colorway : colorway // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,isLimitedEdition: null == isLimitedEdition ? _self.isLimitedEdition : isLimitedEdition // ignore: cast_nullable_to_non_nullable
as bool,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sizesAvailable: null == sizesAvailable ? _self.sizesAvailable : sizesAvailable // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,discountType: freezed == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as String?,discountValue: freezed == discountValue ? _self.discountValue : discountValue // ignore: cast_nullable_to_non_nullable
as double?,releaseType: freezed == releaseType ? _self.releaseType : releaseType // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Product].
extension ProductPatterns on Product {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Product value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Product value)  $default,){
final _that = this;
switch (_that) {
case _Product():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Product value)?  $default,){
final _that = this;
switch (_that) {
case _Product() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String slug,  String? description,  Map<String, dynamic>? detailedDescription,  int price,  int? comparePrice,  int? costPrice, @JsonKey(fromJson: _intFromJson)  int stock,  String? categoryId,  String? brand, @JsonKey(name: 'model')  String? productModel,  String? colorway,  String? sku,  bool isLimitedEdition,  bool isFeatured,  bool isActive, @JsonKey(fromJson: _sizesFromJson)  Map<String, dynamic> sizesAvailable, @JsonKey(fromJson: _stringListFromJson)  List<String> images, @JsonKey(fromJson: _stringListFromJson)  List<String> tags, @JsonKey(fromJson: _dateTimeFromJson)  DateTime createdAt,  String? discountType,  double? discountValue,  String? releaseType,  String? releaseDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.description,_that.detailedDescription,_that.price,_that.comparePrice,_that.costPrice,_that.stock,_that.categoryId,_that.brand,_that.productModel,_that.colorway,_that.sku,_that.isLimitedEdition,_that.isFeatured,_that.isActive,_that.sizesAvailable,_that.images,_that.tags,_that.createdAt,_that.discountType,_that.discountValue,_that.releaseType,_that.releaseDate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String slug,  String? description,  Map<String, dynamic>? detailedDescription,  int price,  int? comparePrice,  int? costPrice, @JsonKey(fromJson: _intFromJson)  int stock,  String? categoryId,  String? brand, @JsonKey(name: 'model')  String? productModel,  String? colorway,  String? sku,  bool isLimitedEdition,  bool isFeatured,  bool isActive, @JsonKey(fromJson: _sizesFromJson)  Map<String, dynamic> sizesAvailable, @JsonKey(fromJson: _stringListFromJson)  List<String> images, @JsonKey(fromJson: _stringListFromJson)  List<String> tags, @JsonKey(fromJson: _dateTimeFromJson)  DateTime createdAt,  String? discountType,  double? discountValue,  String? releaseType,  String? releaseDate)  $default,) {final _that = this;
switch (_that) {
case _Product():
return $default(_that.id,_that.name,_that.slug,_that.description,_that.detailedDescription,_that.price,_that.comparePrice,_that.costPrice,_that.stock,_that.categoryId,_that.brand,_that.productModel,_that.colorway,_that.sku,_that.isLimitedEdition,_that.isFeatured,_that.isActive,_that.sizesAvailable,_that.images,_that.tags,_that.createdAt,_that.discountType,_that.discountValue,_that.releaseType,_that.releaseDate);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String slug,  String? description,  Map<String, dynamic>? detailedDescription,  int price,  int? comparePrice,  int? costPrice, @JsonKey(fromJson: _intFromJson)  int stock,  String? categoryId,  String? brand, @JsonKey(name: 'model')  String? productModel,  String? colorway,  String? sku,  bool isLimitedEdition,  bool isFeatured,  bool isActive, @JsonKey(fromJson: _sizesFromJson)  Map<String, dynamic> sizesAvailable, @JsonKey(fromJson: _stringListFromJson)  List<String> images, @JsonKey(fromJson: _stringListFromJson)  List<String> tags, @JsonKey(fromJson: _dateTimeFromJson)  DateTime createdAt,  String? discountType,  double? discountValue,  String? releaseType,  String? releaseDate)?  $default,) {final _that = this;
switch (_that) {
case _Product() when $default != null:
return $default(_that.id,_that.name,_that.slug,_that.description,_that.detailedDescription,_that.price,_that.comparePrice,_that.costPrice,_that.stock,_that.categoryId,_that.brand,_that.productModel,_that.colorway,_that.sku,_that.isLimitedEdition,_that.isFeatured,_that.isActive,_that.sizesAvailable,_that.images,_that.tags,_that.createdAt,_that.discountType,_that.discountValue,_that.releaseType,_that.releaseDate);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _Product extends Product {
  const _Product({required this.id, required this.name, required this.slug, this.description, final  Map<String, dynamic>? detailedDescription, required this.price, this.comparePrice, this.costPrice, @JsonKey(fromJson: _intFromJson) this.stock = 0, this.categoryId, this.brand, @JsonKey(name: 'model') this.productModel, this.colorway, this.sku, this.isLimitedEdition = false, this.isFeatured = false, this.isActive = true, @JsonKey(fromJson: _sizesFromJson) final  Map<String, dynamic> sizesAvailable = const {}, @JsonKey(fromJson: _stringListFromJson) final  List<String> images = const [], @JsonKey(fromJson: _stringListFromJson) final  List<String> tags = const [], @JsonKey(fromJson: _dateTimeFromJson) required this.createdAt, this.discountType, this.discountValue, this.releaseType, this.releaseDate}): _detailedDescription = detailedDescription,_sizesAvailable = sizesAvailable,_images = images,_tags = tags,super._();
  factory _Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);

@override final  String id;
@override final  String name;
@override final  String slug;
@override final  String? description;
 final  Map<String, dynamic>? _detailedDescription;
@override Map<String, dynamic>? get detailedDescription {
  final value = _detailedDescription;
  if (value == null) return null;
  if (_detailedDescription is EqualUnmodifiableMapView) return _detailedDescription;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  int price;
@override final  int? comparePrice;
@override final  int? costPrice;
@override@JsonKey(fromJson: _intFromJson) final  int stock;
@override final  String? categoryId;
@override final  String? brand;
@override@JsonKey(name: 'model') final  String? productModel;
@override final  String? colorway;
@override final  String? sku;
@override@JsonKey() final  bool isLimitedEdition;
@override@JsonKey() final  bool isFeatured;
@override@JsonKey() final  bool isActive;
 final  Map<String, dynamic> _sizesAvailable;
@override@JsonKey(fromJson: _sizesFromJson) Map<String, dynamic> get sizesAvailable {
  if (_sizesAvailable is EqualUnmodifiableMapView) return _sizesAvailable;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_sizesAvailable);
}

 final  List<String> _images;
@override@JsonKey(fromJson: _stringListFromJson) List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

 final  List<String> _tags;
@override@JsonKey(fromJson: _stringListFromJson) List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey(fromJson: _dateTimeFromJson) final  DateTime createdAt;
@override final  String? discountType;
@override final  double? discountValue;
@override final  String? releaseType;
@override final  String? releaseDate;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductCopyWith<_Product> get copyWith => __$ProductCopyWithImpl<_Product>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Product&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._detailedDescription, _detailedDescription)&&(identical(other.price, price) || other.price == price)&&(identical(other.comparePrice, comparePrice) || other.comparePrice == comparePrice)&&(identical(other.costPrice, costPrice) || other.costPrice == costPrice)&&(identical(other.stock, stock) || other.stock == stock)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.productModel, productModel) || other.productModel == productModel)&&(identical(other.colorway, colorway) || other.colorway == colorway)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.isLimitedEdition, isLimitedEdition) || other.isLimitedEdition == isLimitedEdition)&&(identical(other.isFeatured, isFeatured) || other.isFeatured == isFeatured)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other._sizesAvailable, _sizesAvailable)&&const DeepCollectionEquality().equals(other._images, _images)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.discountType, discountType) || other.discountType == discountType)&&(identical(other.discountValue, discountValue) || other.discountValue == discountValue)&&(identical(other.releaseType, releaseType) || other.releaseType == releaseType)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,slug,description,const DeepCollectionEquality().hash(_detailedDescription),price,comparePrice,costPrice,stock,categoryId,brand,productModel,colorway,sku,isLimitedEdition,isFeatured,isActive,const DeepCollectionEquality().hash(_sizesAvailable),const DeepCollectionEquality().hash(_images),const DeepCollectionEquality().hash(_tags),createdAt,discountType,discountValue,releaseType,releaseDate]);

@override
String toString() {
  return 'Product(id: $id, name: $name, slug: $slug, description: $description, detailedDescription: $detailedDescription, price: $price, comparePrice: $comparePrice, costPrice: $costPrice, stock: $stock, categoryId: $categoryId, brand: $brand, productModel: $productModel, colorway: $colorway, sku: $sku, isLimitedEdition: $isLimitedEdition, isFeatured: $isFeatured, isActive: $isActive, sizesAvailable: $sizesAvailable, images: $images, tags: $tags, createdAt: $createdAt, discountType: $discountType, discountValue: $discountValue, releaseType: $releaseType, releaseDate: $releaseDate)';
}


}

/// @nodoc
abstract mixin class _$ProductCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$ProductCopyWith(_Product value, $Res Function(_Product) _then) = __$ProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String slug, String? description, Map<String, dynamic>? detailedDescription, int price, int? comparePrice, int? costPrice,@JsonKey(fromJson: _intFromJson) int stock, String? categoryId, String? brand,@JsonKey(name: 'model') String? productModel, String? colorway, String? sku, bool isLimitedEdition, bool isFeatured, bool isActive,@JsonKey(fromJson: _sizesFromJson) Map<String, dynamic> sizesAvailable,@JsonKey(fromJson: _stringListFromJson) List<String> images,@JsonKey(fromJson: _stringListFromJson) List<String> tags,@JsonKey(fromJson: _dateTimeFromJson) DateTime createdAt, String? discountType, double? discountValue, String? releaseType, String? releaseDate
});




}
/// @nodoc
class __$ProductCopyWithImpl<$Res>
    implements _$ProductCopyWith<$Res> {
  __$ProductCopyWithImpl(this._self, this._then);

  final _Product _self;
  final $Res Function(_Product) _then;

/// Create a copy of Product
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? slug = null,Object? description = freezed,Object? detailedDescription = freezed,Object? price = null,Object? comparePrice = freezed,Object? costPrice = freezed,Object? stock = null,Object? categoryId = freezed,Object? brand = freezed,Object? productModel = freezed,Object? colorway = freezed,Object? sku = freezed,Object? isLimitedEdition = null,Object? isFeatured = null,Object? isActive = null,Object? sizesAvailable = null,Object? images = null,Object? tags = null,Object? createdAt = null,Object? discountType = freezed,Object? discountValue = freezed,Object? releaseType = freezed,Object? releaseDate = freezed,}) {
  return _then(_Product(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,detailedDescription: freezed == detailedDescription ? _self._detailedDescription : detailedDescription // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as int,comparePrice: freezed == comparePrice ? _self.comparePrice : comparePrice // ignore: cast_nullable_to_non_nullable
as int?,costPrice: freezed == costPrice ? _self.costPrice : costPrice // ignore: cast_nullable_to_non_nullable
as int?,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as int,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,productModel: freezed == productModel ? _self.productModel : productModel // ignore: cast_nullable_to_non_nullable
as String?,colorway: freezed == colorway ? _self.colorway : colorway // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,isLimitedEdition: null == isLimitedEdition ? _self.isLimitedEdition : isLimitedEdition // ignore: cast_nullable_to_non_nullable
as bool,isFeatured: null == isFeatured ? _self.isFeatured : isFeatured // ignore: cast_nullable_to_non_nullable
as bool,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,sizesAvailable: null == sizesAvailable ? _self._sizesAvailable : sizesAvailable // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,discountType: freezed == discountType ? _self.discountType : discountType // ignore: cast_nullable_to_non_nullable
as String?,discountValue: freezed == discountValue ? _self.discountValue : discountValue // ignore: cast_nullable_to_non_nullable
as double?,releaseType: freezed == releaseType ? _self.releaseType : releaseType // ignore: cast_nullable_to_non_nullable
as String?,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
