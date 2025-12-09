// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Customer _$CustomerFromJson(Map<String, dynamic> json) => Customer(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  nickName: json['nick_name'] as String?,
  phone: json['phone'] as String?,
  lineId: json['line_id'] as String?,
  lineUserId: json['line_user_id'] as String?,
  lineDisplayName: json['line_display_name'] as String?,
  linePictureUrl: json['line_picture_url'] as String?,
  appleUserId: json['apple_user_id'] as String?,
  appleEmail: json['apple_email'] as String?,
  appleFamilyName: json['apple_family_name'] as String?,
  appleGivenName: json['apple_given_name'] as String?,
  createdAt: json['created_at'] as String?,
);

Map<String, dynamic> _$CustomerToJson(Customer instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'nick_name': instance.nickName,
  'phone': instance.phone,
  'line_id': instance.lineId,
  'line_user_id': instance.lineUserId,
  'line_display_name': instance.lineDisplayName,
  'line_picture_url': instance.linePictureUrl,
  'apple_user_id': instance.appleUserId,
  'apple_email': instance.appleEmail,
  'apple_family_name': instance.appleFamilyName,
  'apple_given_name': instance.appleGivenName,
  'created_at': instance.createdAt,
};
