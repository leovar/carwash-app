
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/vehicle_type/model/vehicleType.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Product extends Equatable {
  final String id;
  final String productName;
  final double price;
  final double ivaPercent;
  final DocumentReference vehicleType;
  final List<DocumentReference> locations;
  final bool productActive;
  final int vehicleTypeUid;
  bool isSelected;
  final bool isAdditional;
  bool newProduct;
  final String productType;

  Product({
    this.id,
    this.productName,
    this.price,
    this.ivaPercent,
    this.vehicleType,
    this.locations,
    this.productActive,
    this.vehicleTypeUid,
    this.isSelected,
    this.isAdditional,
    this.newProduct,
    this.productType,
  });

  factory Product.fromJson(Map<String, dynamic> json, {String id}) {
    List<DocumentReference> locationsListDb = <DocumentReference>[];
    List locationsList = json['locations'];
    locationsList?.forEach((drLocation) {
      locationsListDb.add(drLocation);
    });

    return Product(
      id: id,
      productName: json['productName'],
      price: json['price'].toDouble(),
      ivaPercent: json['ivaPercent'].toDouble(),
      vehicleType: json['vehicleType'],
      productActive : json['productActive'],
      vehicleTypeUid : json['vehicleTypeUid'],
      isAdditional: json['isAdditional'],
      locations: locationsListDb,
      isSelected: false,
      productType: json['productType'],
    );
  }

  factory Product.fromJsonProInvoice(Map<String, dynamic> json, {String id}) {
    List<DocumentReference> locationsListDb = <DocumentReference>[];
    List locationsList = json['locations'];
    locationsList?.forEach((drLocation) {
      locationsListDb.add(drLocation);
    });

    return Product(
      id: json['productId'],
      productName: json['productName'],
      price: json['price'].toDouble(),
      ivaPercent: json['ivaPercent'].toDouble(),
      vehicleType: json['vehicleType'],
      productActive : json['productActive'],
      vehicleTypeUid : json['vehicleTypeUid'],
      isAdditional: json['isAdditional'],
      locations: locationsListDb,
      isSelected: true,
      productType: json['productType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': this.productName,
      'price': this.price,
      'ivaPercent' : this.ivaPercent,
      'vehicleType' : this.vehicleType,
      'locations' : this.locations,
      'productActive' : this.productActive,
      'vehicleTypeUid' : this.vehicleTypeUid,
      'productType' : this.productType,
    };
  }

  Map<String, dynamic> toJsonInvoiceProduct(
      String productName,
      double price,
      double ivaPercent,
      bool isAdditional,
      String productId,
      ) {
    return {
      'productName': productName,
      'price': price,
      'ivaPercent': ivaPercent,
      'isAdditional': isAdditional,
      'productId': productId,
    };
  }

  factory Product.copyProductInvoiceWith({
    @required Product origin,
    bool isSelected,
    double price,
    double ivaPercent,
  }) {
    return Product(
      id: origin.id,
      productName: origin.productName,
      price: price ?? origin.price,
      ivaPercent: ivaPercent ?? origin.ivaPercent,
      vehicleType: origin.vehicleType,
      locations: origin.locations,
      productActive: origin.productActive,
      vehicleTypeUid: origin.vehicleTypeUid,
      isSelected: isSelected ?? origin.isSelected,
      isAdditional: origin.isAdditional,
      productType: origin.productType,
    );
  }

  @override
  List<Object> get props => [
    id,
    productName,
    price,
    ivaPercent,
    vehicleType,
    locations,
    productActive,
    vehicleTypeUid,
    isSelected,
    productType,
  ];
}