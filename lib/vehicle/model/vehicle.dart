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

  Vehicle({
    this.id,
    this.brand,
    this.model,
    this.placa,
    this.color,
    this.vehicleType,
    this.creationDate,
    this.brandReference,
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
    };
  }

  @override
  List<Object> get props => [
    id!,
    brand!,
    model!,
    placa!,
    color!,
    vehicleType!,
    creationDate!,
    brandReference!
  ];
}
