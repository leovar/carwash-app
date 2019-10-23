
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class VehicleType extends Equatable {
  final String id;
  final String vehicleType;

  VehicleType({
    this.id,
    this.vehicleType,
  });

  @override
  List<Object> get props => [
    id,
    vehicleType,
  ];
}