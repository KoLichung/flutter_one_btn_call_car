import 'package:json_annotation/json_annotation.dart';

part 'ride_record.g.dart';

@JsonSerializable()
class RideRecord {
  final int id;
  @JsonKey(name: 'case_number')
  final String caseNumber;
  @JsonKey(name: 'case_state')
  final String caseState;
  @JsonKey(name: 'driver_id')
  final int? driverId;
  @JsonKey(name: 'driver_nick_name')
  final String? driverNickName;
  @JsonKey(name: 'driver_name')
  final String? driverName;
  @JsonKey(name: 'on_lat', fromJson: _parseDouble, toJson: _doubleToString)
  final double onLat;
  @JsonKey(name: 'on_lng', fromJson: _parseDouble, toJson: _doubleToString)
  final double onLng;
  @JsonKey(name: 'on_address')
  final String onAddress;
  @JsonKey(name: 'off_lat', fromJson: _parseDoubleNullable, toJson: _doubleToStringNullable)
  final double? offLat;
  @JsonKey(name: 'off_lng', fromJson: _parseDoubleNullable, toJson: _doubleToStringNullable)
  final double? offLng;
  @JsonKey(name: 'off_address')
  final String? offAddress;
  @JsonKey(name: 'create_time')
  final String createTime;
  @JsonKey(name: 'case_money')
  final double? caseMoney;
  @JsonKey(name: 'off_time')
  final String? offTime;
  final String? memo;

  RideRecord({
    required this.id,
    required this.caseNumber,
    required this.caseState,
    this.driverId,
    this.driverNickName,
    this.driverName,
    required this.onLat,
    required this.onLng,
    required this.onAddress,
    this.offLat,
    this.offLng,
    this.offAddress,
    required this.createTime,
    this.caseMoney,
    this.offTime,
    this.memo,
  });

  // 自定义解析方法：处理字符串或数字
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0.0;
  }

  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      if (value.isEmpty) return null;
      return double.parse(value);
    }
    return null;
  }

  static String _doubleToString(double value) => value.toString();
  
  static String? _doubleToStringNullable(double? value) => value?.toString();

  factory RideRecord.fromJson(Map<String, dynamic> json) => _$RideRecordFromJson(json);
  Map<String, dynamic> toJson() => _$RideRecordToJson(this);

  // 获取订单状态的中文显示
  String get statusText {
    switch (caseState) {
      case 'wait':
        return '等待派单';
      case 'dispatching':
        return '派单中';
      case 'way_to_catch':
        return '司机前往中';
      case 'arrived':
        return '司机已到达';
      case 'catched':
        return '已上车';
      case 'on_road':
        return '行驶中';
      case 'finished':
        return '已完成';
      case 'canceled':
        return '已取消';
      default:
        return '未知';
    }
  }

  // 解析创建时间
  DateTime get createDateTime => DateTime.parse(createTime);

  // 解析下车时间
  DateTime? get offDateTime => offTime != null ? DateTime.parse(offTime!) : null;
}

