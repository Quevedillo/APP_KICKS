// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: json['id'] as String,
  email: json['email'] as String,
  fullName: json['full_name'] as String?,
  isAdmin: json['is_admin'] as bool? ?? false,
  isBanned: json['is_banned'] as bool? ?? false,
  createdAt: _nullableDateTimeFromJson(json['created_at']),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'full_name': instance.fullName,
      'is_admin': instance.isAdmin,
      'is_banned': instance.isBanned,
      'created_at': instance.createdAt?.toIso8601String(),
    };
