
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
  final String phoneNumber;
  final DocumentReference vehicle;
  final String placa;
  final int uidVehicleType;
  final DocumentReference location;
  final String locationName;
  final int consecutive;
  final Timestamp creationDate;
  final List<String> invoiceImages;
  final List<Product> invoiceProducts;
  final String vehicleBrand;
  final String vehicleColor;
  final Uint8List imageFirm;
  final bool approveDataProcessing;
  final String timeDelivery;
  final Timestamp closedDate;
  final bool invoiceClosed;
  final String observation;

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
    this.phoneNumber,
    this.vehicle,
    this.placa,
    this.uidVehicleType,
    this.location,
    this.locationName,
    this.consecutive,
    this.creationDate,
    this.invoiceImages,
    this.invoiceProducts,
    this.vehicleBrand,
    this.vehicleColor,
    this.imageFirm,
    this.approveDataProcessing,
    this.timeDelivery,
    this.closedDate,
    this.invoiceClosed,
    this.observation,
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
      'phoneNumber': this.phoneNumber,
      'vehicle': this.vehicle,
      'placa': this.placa,
      'uidVehicleType': this.uidVehicleType,
      'location': this.location,
      'locationName': this.locationName,
      'consecutive': this.consecutive,
      'vehicleBrand': this.vehicleBrand,
      'vehicleColor': this.vehicleColor,
      'creationDate': this.creationDate,
      'approveDataProcessing': this.approveDataProcessing,
      'timeDelivery': this.timeDelivery,
      'closedDate': this.closedDate,
      'invoiceClosed': this.invoiceClosed,
      'observation': this.observation,
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
      phoneNumber: json['phoneNumber'],
      vehicle: json['vehicle'],
      placa: json['placa'],
      uidVehicleType: json['uidVehicleType'],
      location: json['location'],
      locationName: json['locationName'],
      consecutive: json['consecutive'],
      vehicleBrand: json['vehicleBrand'],
      vehicleColor: json['vehicleColor'],
      creationDate: json['creationDate'],
      approveDataProcessing: json['approveDataProcessing'],
      timeDelivery: json['timeDelivery'],
      closedDate: json['closedDate'],
      invoiceClosed: json['invoiceClosed'],
      observation: json['observation'],
    );
  }

  factory Invoice.copyWith({
    @required Invoice origin,
    Timestamp closedDate,
    bool invoiceClosed,
    List<Product> listProducts,
  }) {
    return Invoice(
      id: origin.id,
      totalPrice: origin.totalPrice,
      subtotal: origin.subtotal,
      iva: origin.iva,
      userOwner: origin.userOwner,
      userOperator: origin.userOperator,
      userOperatorName: origin.userOperatorName,
      userCoordinator: origin.userCoordinator,
      userCoordinatorName: origin.userCoordinatorName,
      customer: origin.customer,
      phoneNumber: origin.phoneNumber,
      vehicle: origin.vehicle,
      placa: origin.placa,
      uidVehicleType: origin.uidVehicleType,
      location: origin.location,
      locationName: origin.locationName,
      consecutive: origin.consecutive,
      vehicleBrand: origin.vehicleBrand,
      vehicleColor: origin.vehicleColor,
      creationDate: origin.creationDate,
      invoiceProducts: listProducts ?? origin.invoiceProducts,
      approveDataProcessing: origin.approveDataProcessing,
      timeDelivery: origin.timeDelivery,
      closedDate: closedDate ?? origin.closedDate,
      invoiceClosed: invoiceClosed ?? origin.invoiceClosed,
      observation: origin.observation,
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
    phoneNumber,
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
    vehicleBrand,
    vehicleColor,
    timeDelivery,
    closedDate,
    invoiceClosed,
    observation,
  ];
}