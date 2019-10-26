
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class VehicleType extends Equatable {
  final String id;
  final String vehicleType;

  VehicleType({
    this.id,
    this.vehicleType,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json, {String id}) {
    return VehicleType(
      id: id,
      vehicleType: json['vehicleType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleType': this.vehicleType,
    };
  }

  @override
  List<Object> get props => [
    id,
    vehicleType,
  ];
}