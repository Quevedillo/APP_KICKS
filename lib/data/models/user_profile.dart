import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

DateTime? _nullableDateTimeFromJson(dynamic v) =>
    v is String ? DateTime.tryParse(v) : null;

@freezed
abstract class UserProfile with _$UserProfile {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserProfile({
    required String id,
    required String email,
    String? fullName,
    @Default(false) bool isAdmin,
    @Default(false) bool isBanned,
    @JsonKey(fromJson: _nullableDateTimeFromJson) DateTime? createdAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
