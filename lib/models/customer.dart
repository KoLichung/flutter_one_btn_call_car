import 'package:json_annotation/json_annotation.dart';

part 'customer.g.dart';

@JsonSerializable()
class Customer {
  final int id;
  final String name;
  @JsonKey(name: 'nick_name')
  final String? nickName;
  final String? phone;
  @JsonKey(name: 'line_id')
  final String? lineId;
  @JsonKey(name: 'line_user_id')
  final String? lineUserId;
  @JsonKey(name: 'line_display_name')
  final String? lineDisplayName;
  @JsonKey(name: 'line_picture_url')
  final String? linePictureUrl;
  @JsonKey(name: 'apple_user_id')
  final String? appleUserId;
  @JsonKey(name: 'apple_email')
  final String? appleEmail;
  @JsonKey(name: 'apple_family_name')
  final String? appleFamilyName;
  @JsonKey(name: 'apple_given_name')
  final String? appleGivenName;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  Customer({
    required this.id,
    required this.name,
    this.nickName,
    this.phone,
    this.lineId,
    this.lineUserId,
    this.lineDisplayName,
    this.linePictureUrl,
    this.appleUserId,
    this.appleEmail,
    this.appleFamilyName,
    this.appleGivenName,
    this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);

  // 获取显示名称（优先使用 nickName，否则使用 name）
  String get displayName => nickName ?? name;

  // 判断登录方式
  String get loginMethod {
    if (lineUserId != null && lineUserId!.isNotEmpty) {
      return 'line';
    } else if (appleUserId != null && appleUserId!.isNotEmpty) {
      return 'apple';
    } else if (phone != null && phone!.isNotEmpty) {
      return 'phone';
    }
    return 'unknown';
  }
}

