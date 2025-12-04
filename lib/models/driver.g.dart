// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Driver _$DriverFromJson(Map<String, dynamic> json) => Driver(
  id: (json['id'] as num).toInt(),
  nickName: json['nick_name'] as String,
  name: json['name'] as String,
  carLicence: json['car_licence'] as String,
  carColor: json['car_color'] as String,
  numberSites: (json['number_sites'] as num).toInt(),
  phone: json['phone'] as String,
);

Map<String, dynamic> _$DriverToJson(Driver instance) => <String, dynamic>{
  'id': instance.id,
  'nick_name': instance.nickName,
  'name': instance.name,
  'car_licence': instance.carLicence,
  'car_color': instance.carColor,
  'number_sites': instance.numberSites,
  'phone': instance.phone,
};
