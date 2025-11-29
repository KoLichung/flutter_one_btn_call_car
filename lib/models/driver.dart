import 'package:json_annotation/json_annotation.dart';

part 'driver.g.dart';

@JsonSerializable()
class Driver {
  final int id;
  @JsonKey(name: 'nick_name')
  final String nickName;
  final String name;
  @JsonKey(name: 'car_licence')
  final String carLicence;
  @JsonKey(name: 'car_color')
  final String carColor;
  @JsonKey(name: 'number_sites')
  final int numberSites;
  final String phone;

  Driver({
    required this.id,
    required this.nickName,
    required this.name,
    required this.carLicence,
    required this.carColor,
    required this.numberSites,
    required this.phone,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => _$DriverFromJson(json);
  Map<String, dynamic> toJson() => _$DriverToJson(this);
}

