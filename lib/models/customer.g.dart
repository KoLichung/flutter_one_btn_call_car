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
      'created_at': instance.createdAt,
    };

