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
  final String customerName;
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
  final String productsSplit;
  final String vehicleBrand;
  final String brandReference;
  final String vehicleColor;
  final Uint8List imageFirm;
  final bool approveDataProcessing;
  final String timeDelivery;
  final Timestamp closedDate;
  final bool invoiceClosed;
  final String observation;
  final String incidence;
  final bool haveSpecialService;
  final int countProducts;
  final int countAdditionalProducts;
  final bool sendEmailInvoice;
  final bool cancelledInvoice;
  final String paymentMethod;
  final int washingServicesTime;
  final bool startWashing;
  final String washingCell;
  final Timestamp dateStartWashing;
  final int countWashingWorkers;
  final bool endWash;
  final Timestamp dateEndWash;
  final int washingTime;
  final List<User> operatorUsers;
  final String operatorsSplit;
  final int countOperators;

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
    this.customerName,
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
    this.productsSplit,
    this.vehicleBrand,
    this.brandReference,
    this.vehicleColor,
    this.imageFirm,
    this.approveDataProcessing,
    this.timeDelivery,
    this.closedDate,
    this.invoiceClosed,
    this.observation,
    this.incidence,
    this.haveSpecialService,
    this.countProducts,
    this.countAdditionalProducts,
    this.sendEmailInvoice,
    this.cancelledInvoice,
    this.paymentMethod,
    this.startWashing,
    this.washingCell,
    this.dateStartWashing,
    this.dateEndWash,
    this.countWashingWorkers,
    this.endWash,
    this.washingServicesTime,
    this.washingTime,
    this.operatorUsers,
    this.operatorsSplit,
    this.countOperators,
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
      'brandReference': this.brandReference,
      'vehicleColor': this.vehicleColor,
      'creationDate': this.creationDate,
      'approveDataProcessing': this.approveDataProcessing,
      'timeDelivery': this.timeDelivery,
      'closedDate': this.closedDate,
      'invoiceClosed': this.invoiceClosed,
      'observation': this.observation,
      'incidence': this.incidence,
      'haveSpecialService': this.haveSpecialService,
      'countProducts': this.countProducts,
      'countAdditionalProducts': this.countAdditionalProducts,
      'sendEmailInvoice': this.sendEmailInvoice,
      'cancelledInvoice': this.cancelledInvoice,
      'paymentMethod' : this.paymentMethod,
      'startWashing' : this.startWashing,
      'washingCell' : this.washingCell,
      'dateStartWashing' : this.dateStartWashing,
      'dateEndWash' : this.dateEndWash,
      'countWashingWorkers' : this.countWashingWorkers,
      'endWash' : this.endWash,
      'washingServicesTime' : this.washingServicesTime,
      'washingTime' : this.washingTime,
      'countOperators' : this.countOperators,
    };
  }

  factory Invoice.fromJson(Map<String, dynamic> json, {String id}) {
    List<DocumentReference> locationsListDb = <DocumentReference>[];
    List<Product> listProducts = <Product>[];
    List<User> listOperators = <User>[];
    var pSplit = '';
    var oSplit = '';
    List locationsList = json['locations'];
    locationsList?.forEach((drLocation) {
      locationsListDb.add(drLocation);
    });
    var products = json['invoiceProducts'];
    products?.forEach((element) {
      Product productResult = Product.fromJsonProductIntoInvoice(element, json['uidVehicleType'], json['creationDate']);
      listProducts.add(productResult);
      pSplit = pSplit + productResult.productName + ', ';
    });
    var operators = json['operatorUsers'];
    operators?.forEach((item) {
      User userResult = User.fromJsonOperatorIntoInvoice(item);
      listOperators.add(userResult);
      oSplit = oSplit + userResult.name + ', ';
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
      brandReference: json['brandReference'],
      vehicleColor: json['vehicleColor'],
      creationDate: json['creationDate'],
      approveDataProcessing: json['approveDataProcessing'],
      timeDelivery: json['timeDelivery'],
      closedDate: json['closedDate'],
      invoiceClosed: json['invoiceClosed'],
      observation: json['observation'],
      incidence: json['incidence'],
      haveSpecialService: json['haveSpecialService'],
      countProducts: json['countProducts'],
      countAdditionalProducts: json['countAdditionalProducts'],
      sendEmailInvoice: json['sendEmailInvoice'],
      invoiceProducts: listProducts,
      productsSplit: pSplit,
      cancelledInvoice: json['cancelledInvoice']??false,
      paymentMethod: json['paymentMethod'],
      startWashing : json['startWashing']??false,
      washingCell : json['washingCell'],
      dateStartWashing : json['dateStartWashing'],
      dateEndWash : json['dateEndWash'],
      countWashingWorkers : json['countWashingWorkers'],
      endWash : json['endWash']??false,
      washingServicesTime : json['washingServicesTime'],
      washingTime : json['washingTime'],
      operatorUsers : listOperators,
      operatorsSplit : oSplit,
      countOperators : json['countOperators'],
    );
  }

  factory Invoice.copyWith({
    @required Invoice origin,
    Timestamp closedDate,
    bool invoiceClosed,
    List<Product> listProducts,
    int countProducts,
    int countAdditionalProducts,
    DocumentReference userOperator,
    String userOperatorName,
    String paymentMethod,
    String customerName,
    String customerPhone,
    bool cancelledInvoice,
    bool startWashing,
    bool endWash,
    String washingCell,
    Timestamp dateStartWashing,
    Timestamp dateEndWash,
    int countWashingWorkers,
    int washingTime,
    List<User> listOperators,
    int countOperators,
  }) {
    return Invoice(
      id: origin.id,
      totalPrice: origin.totalPrice,
      subtotal: origin.subtotal,
      iva: origin.iva,
      userOwner: origin.userOwner,
      userOperator: userOperator ?? origin.userOperator,
      userOperatorName: userOperatorName ?? origin.userOperatorName,
      userCoordinator: origin.userCoordinator,
      userCoordinatorName: origin.userCoordinatorName,
      customer: origin.customer,
      customerName: customerName ?? origin.customerName,
      phoneNumber: customerPhone ?? origin.phoneNumber,
      vehicle: origin.vehicle,
      placa: origin.placa,
      uidVehicleType: origin.uidVehicleType,
      location: origin.location,
      locationName: origin.locationName,
      consecutive: origin.consecutive,
      vehicleBrand: origin.vehicleBrand,
      brandReference: origin.brandReference,
      vehicleColor: origin.vehicleColor,
      creationDate: origin.creationDate,
      invoiceProducts: listProducts ?? origin.invoiceProducts,
      productsSplit: origin.productsSplit,
      approveDataProcessing: origin.approveDataProcessing,
      timeDelivery: origin.timeDelivery,
      closedDate: closedDate ?? origin.closedDate,
      invoiceClosed: invoiceClosed ?? origin.invoiceClosed,
      observation: origin.observation,
      incidence: origin.incidence,
      haveSpecialService: origin.haveSpecialService,
      countProducts: countProducts ?? origin.countProducts,
      countAdditionalProducts:
          countAdditionalProducts ?? origin.countAdditionalProducts,
      sendEmailInvoice: origin.sendEmailInvoice,
      cancelledInvoice: cancelledInvoice ?? origin.cancelledInvoice,
      paymentMethod: paymentMethod ?? origin.paymentMethod,
      startWashing : startWashing ?? origin.startWashing,
      washingCell : washingCell ?? origin.washingCell,
      dateStartWashing : dateStartWashing ?? origin.dateStartWashing,
      dateEndWash : dateEndWash ?? origin.dateEndWash,
      countWashingWorkers : countWashingWorkers ?? origin.countWashingWorkers,
      endWash : endWash ?? origin.endWash,
      washingServicesTime : origin.washingServicesTime,
      washingTime : washingTime ?? origin.washingTime,
      operatorUsers: listOperators ?? origin.operatorUsers,
      operatorsSplit : origin.operatorsSplit,
      countOperators : countOperators ?? origin.countOperators,
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
        customerName,
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
        brandReference,
        vehicleColor,
        timeDelivery,
        closedDate,
        invoiceClosed,
        observation,
        incidence,
        haveSpecialService,
        countProducts,
        countAdditionalProducts,
        sendEmailInvoice,
        cancelledInvoice,
        paymentMethod,
        startWashing,
        washingCell,
        dateStartWashing,
        dateEndWash,
        countWashingWorkers,
        endWash,
        washingServicesTime,
        washingTime,
        operatorUsers,
        operatorsSplit,
        countOperators,
      ];
}
