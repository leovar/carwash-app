
import 'dart:typed_data';

import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/vehicle/model/vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';


@immutable
class Invoice extends Equatable {
  final String id;
  final double totalPrice;
  final double subtotal;
  final double iva;
  final DocumentReference userOwner;
  final DocumentReference userOperator;
  final String userOperatorName;
  final DocumentReference userCoordinator;
  final String userCoordinatorName;
  final DocumentReference customer;
  final DocumentReference vehicle;
  final String placa;
  final int uidVehicleType;
  final DocumentReference location;
  final String locationName;
  final int consecutive;
  final Timestamp creationDate;
  final List<String> invoiceImages;
  final List<Product> invoiceProducts;
  final Uint8List imageFirm;
  final bool approveDataProcessing;

  Invoice({
    this.id,
    this.totalPrice,
    this.subtotal,
    this.iva,
    this.userOwner,
    this.userOperator,
    this.userOperatorName,
    this.userCoordinator,
    this.userCoordinatorName,
    this.customer,
    this.vehicle,
    this.placa,
    this.uidVehicleType,
    this.location,
    this.locationName,
    this.consecutive,
    this.creationDate,
    this.invoiceImages,
    this.invoiceProducts,
    this.imageFirm,
    this.approveDataProcessing,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalPrice': this.totalPrice,
      'subtotal': this.subtotal,
      'iva': this.iva,
      'userOwner': this.userOwner,
      'userOperator': this.userOperator,
      'userOperatorName': this.userOperatorName,
      'userCoordinator': this.userCoordinator,
      'userCoordinatorName': this.userCoordinatorName,
      'customer': this.customer,
      'vehicle': this.vehicle,
      'placa': this.placa,
      'uidVehicleType': this.uidVehicleType,
      'location': this.location,
      'locationName': this.locationName,
      'consecutive': this.consecutive,
      'creationDate': this.creationDate,
      'approveDataProcessing': this.approveDataProcessing,
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json, {String id}) {
    List<DocumentReference> locationsListDb = <DocumentReference>[];
    List locationsList = json['locations'];
    locationsList?.forEach((drLocation) {
      locationsListDb.add(drLocation);
    });

    return Invoice(
      id: id ?? '',
      totalPrice: json['totalPrice'].toDouble(),
      subtotal: json['subtotal'].toDouble(),
      iva: json['iva'].toDouble(),
      userOwner: json['userOwner'],
      userOperator: json['userOperator'],
      userOperatorName: json['userOperatorName'],
      userCoordinator: json['userCoordinator'],
      userCoordinatorName: json['userCoordinatorName'],
      customer: json['customer'],
      vehicle: json['vehicle'],
      placa: json['placa'],
      uidVehicleType: json['uidVehicleType'],
      location: json['location'],
      locationName: json['locationName'],
      consecutive: json['consecutive'],
      creationDate: json['creationDate'],
      approveDataProcessing: json['approveDataProcessing'],
    );
  }


  @override
  List<Object> get props => [
    id,
    totalPrice,
    subtotal,
    iva,
    userOwner,
    userOperator,
    userOperatorName,
    userCoordinator,
    customer,
    vehicle,
    placa,
    uidVehicleType,
    location,
    locationName,
    consecutive,
    creationDate,
    invoiceImages,
    invoiceProducts,
    approveDataProcessing,
  ];
}