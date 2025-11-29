// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RideRecord _$RideRecordFromJson(Map<String, dynamic> json) => RideRecord(
      id: (json['id'] as num).toInt(),
      caseNumber: json['case_number'] as String,
      caseState: json['case_state'] as String,
      driverId: (json['driver_id'] as num?)?.toInt(),
      driverNickName: json['driver_nick_name'] as String?,
      driverName: json['driver_name'] as String?,
      onLat: (json['on_lat'] as num).toDouble(),
      onLng: (json['on_lng'] as num).toDouble(),
      onAddress: json['on_address'] as String,
      offLat: (json['off_lat'] as num?)?.toDouble(),
      offLng: (json['off_lng'] as num?)?.toDouble(),
      offAddress: json['off_address'] as String?,
      createTime: json['create_time'] as String,
      caseMoney: (json['case_money'] as num?)?.toDouble(),
      offTime: json['off_time'] as String?,
      memo: json['memo'] as String?,
    );

Map<String, dynamic> _$RideRecordToJson(RideRecord instance) => <String, dynamic>{
      'id': instance.id,
      'case_number': instance.caseNumber,
      'case_state': instance.caseState,
      'driver_id': instance.driverId,
      'driver_nick_name': instance.driverNickName,
      'driver_name': instance.driverName,
      'on_lat': instance.onLat,
      'on_lng': instance.onLng,
      'on_address': instance.onAddress,
      'off_lat': instance.offLat,
      'off_lng': instance.offLng,
      'off_address': instance.offAddress,
      'create_time': instance.createTime,
      'case_money': instance.caseMoney,
      'off_time': instance.offTime,
      'memo': instance.memo,
    };

