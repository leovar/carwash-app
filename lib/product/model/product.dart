
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/vehicle_type/model/vehicleType.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Product extends Equatable {
  final String id;
  final String productName;
  final double price;
  final double iva;
  final VehicleType vehicleType;
  final List<String> locations;

  Product({
    this.id,
    this.productName,
    this.price,
    this.iva,
    this.vehicleType,
    this.locations,
  });

  @override
  List<Object> get props => [
    id,
    productName,
    price,
    iva,
    vehicleType,
    locations,
  ];
}