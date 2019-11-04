
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
  final double iva;
  final String ivaPercent;
  final DocumentReference vehicleType;
  final List<DocumentReference> locations;
  bool isSelected;

  Product({
    this.id,
    this.productName,
    this.price,
    this.iva,
    this.ivaPercent,
    this.vehicleType,
    this.locations,
    this.isSelected,
  });

  factory Product.fromJson(Map<String, dynamic> json, {String id}) {
    List<DocumentReference> locationsListDb = <DocumentReference>[];
    List locationslist = json['locations'];
    locationslist?.forEach((drLocation) {
      locationsListDb.add(drLocation);
    });

    return Product(
      id: id,
      productName: json['productName'],
      price: json['price'].toDouble(),
      iva: json['iva'].toDouble(),
      ivaPercent: json['ivaPercent'],
      vehicleType: json['vehicleType'],
      locations: locationsListDb,
      isSelected: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': this.productName,
      'price': this.price,
      'iva' : this.iva,
      'ivaPercent' : this.ivaPercent,
      'vehicleType' : this.vehicleType,
      'locations' : this.locations,
    };
  }

  Map<String, dynamic> toJsonInvoiceProduct(
      String productName,
      double price,
      double iva,
      bool isAdditional,
      ) {
    return {
      'productName': productName,
      'price': price,
      'iva': iva,
      'isAdditional': isAdditional,
    };
  }

  @override
  List<Object> get props => [
    id,
    productName,
    price,
    iva,
    ivaPercent,
    vehicleType,
    locations,
  ];
}