import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

@immutable
class Vehicle extends Equatable {
  final String? id;
  final String? brand;
  final String? model;
  final String? placa;
  final String? color;
  final String? vehicleType;
  final Timestamp? creationDate;
  final String? brandReference;
  final String companyId;

  Vehicle({
    this.id,
    this.brand,
    this.model,
    this.placa,
    this.color,
    this.vehicleType,
    this.creationDate,
    this.brandReference,
    required this.companyId,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json, {String? id}) {
    return Vehicle(
      id: id,
      brand: json['brand'],
      model: json['model'],
      placa: json['placa'],
      color: json['color'],
      vehicleType: json['vehicleType'],
      creationDate: json['creationDate'],
      brandReference: json['brandReference'],
      companyId: json['companyId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': this.brand,
      'model': this.model,
      'placa': this.placa,
      'color': this.color,
      'vehicleType': this.vehicleType,
      'creationDate': this.creationDate,
      'brandReference': this.brandReference,
      'companyId': this.companyId,
    };
  }

  @override
  List<Object> get props => [
    id ?? '',
    brand ?? '',
    model ?? '',
    placa ?? '',
    color ?? '',
    vehicleType ?? '',
    creationDate ?? new DateTime.timestamp(),
    brandReference ?? '',
    companyId
  ];
}
