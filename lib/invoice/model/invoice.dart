
import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/vehicle/model/vehicle.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';


@immutable
class Invoice extends Equatable {
  final String id;
  final Product product;
  final double totalPrice;
  final double subtotal;
  final double iva;
  final User userOwner;
  final Customer customer;
  final Vehicle vehicle;
  final Location location;
  final int consecutive;

  Invoice({
    this.id,
    this.product,
    this.totalPrice,
    this.subtotal,
    this.iva,
    this.userOwner,
    this.customer,
    this.vehicle,
    this.location,
    this.consecutive,
  });

  @override
  List<Object> get props => [
    id,
    product,
    totalPrice,
    subtotal,
    iva,
    userOwner,
    customer,
    vehicle,
    location,
    consecutive,
  ];
}