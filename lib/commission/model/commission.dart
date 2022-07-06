import 'package:car_wash_app/vehicle_type/model/vehicleType.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Commission extends Equatable {
  final String id;
  final int uidVehicleType;
  final String productType;
  final bool isPercentage;
  final bool isValue;
  final double value;

  Commission({
    this.id,
    this.uidVehicleType,
    this.productType,
    this.isPercentage,
    this.isValue,
    this.value,
  });

  factory Commission.fromJson(Map<String, dynamic> json, {String id}) {
    return Commission(
      id: id,
      uidVehicleType: json['uidVehicleType'],
      productType: json['productType'],
      isPercentage: json['isPercentage'],
      isValue: json['isValue'],
      value: json['value'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uidVehicleType': this.uidVehicleType,
      'productType': this.productType,
      'isPercentage': this.isPercentage,
      'isValue': this.isValue,
      'value': this.value,
    };
  }

  @override
  List<Object> get props => [
        id,
        uidVehicleType,
        productType,
        isPercentage,
        isValue,
        value,
      ];
}
