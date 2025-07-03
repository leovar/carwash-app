import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

@immutable
class Brand extends Equatable {
  final String? id;
  final String? brand;
  final int? vehicleType;

  Brand({
   this.id,
   this.brand,
   this.vehicleType,
  });

  factory Brand.fromJson(Map<String, dynamic> json, {required String id}) {
    return Brand(
      id: id,
      brand: json['brand'],
      vehicleType: json['vehicleType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': this.brand,
      'vehicleType': this.vehicleType,
    };
  }

  @override
  List<Object> get props => [
    id ?? '',
    brand ?? '',
    vehicleType ?? 0,
  ];

}