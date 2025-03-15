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
  final bool calculatePerCount;
  final double commissionThreshold;
  final double valueBeforeThreshold;

  Commission({
    this.id,
    this.uidVehicleType,
    this.productType,
    this.isPercentage,
    this.isValue,
    this.value,
    this.calculatePerCount,
    this.commissionThreshold,
    this.valueBeforeThreshold,
  });

  factory Commission.fromJson(Map<String, dynamic> json, {String id}) {
    return Commission(
      id: id,
      uidVehicleType: json['uidVehicleType'],
      productType: json['productType'],
      isPercentage: json['isPercentage'],
      isValue: json['isValue'],
      value: json['value'].toDouble(),
      calculatePerCount : json['calculatePerCount'],
      commissionThreshold : json['commissionThreshold'].toDouble(),
      valueBeforeThreshold : json['valueBeforeThreshold'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uidVehicleType': this.uidVehicleType,
      'productType': this.productType,
      'isPercentage': this.isPercentage,
      'isValue': this.isValue,
      'value': this.value,
      'calculatePerCount': this.calculatePerCount,
      'commissionThreshold': this.commissionThreshold,
      'valueBeforeThreshold': this.valueBeforeThreshold,
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
        calculatePerCount,
        commissionThreshold,
        valueBeforeThreshold,
      ];
}
