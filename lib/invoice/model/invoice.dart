
import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/location/model/location.dart';
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
  final DocumentReference userCoordinator;
  final DocumentReference customer;
  final DocumentReference vehicle;
  final DocumentReference location;
  final int consecutive;
  final List<String> invoiceImages;

  Invoice({
    this.id,
    this.totalPrice,
    this.subtotal,
    this.iva,
    this.userOwner,
    this.userOperator,
    this.userCoordinator,
    this.customer,
    this.vehicle,
    this.location,
    this.consecutive,
    this.invoiceImages,
  });

  Map<String, dynamic> toJson() {
    return {
      'totalPrice': this.totalPrice,
      'subtotal': this.subtotal,
      'iva': this.iva,
      'userOwner': this.userOwner,
      'userOperator': this.userOperator,
      'userCoordinator': this.userCoordinator,
      'customer': this.customer,
      'vehicle': this.vehicle,
      'location': this.location,
      'consecutive': this.consecutive,
    };
  }


  @override
  List<Object> get props => [
    id,
    totalPrice,
    subtotal,
    iva,
    userOwner,
    customer,
    vehicle,
    location,
    consecutive,
    invoiceImages,
  ];
}