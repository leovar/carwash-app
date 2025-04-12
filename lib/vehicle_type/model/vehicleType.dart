
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class VehicleType extends Equatable {
  final String? id;
  final int? uid;
  final String vehicleType;

  VehicleType({
    this.id,
    this.uid,
    required this.vehicleType,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json, {required String id}) {
    return VehicleType(
      id: id,
      uid: json['uid'],
      vehicleType: json['vehicleType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': this.uid,
      'vehicleType': this.vehicleType,
    };
  }

  @override
  List<Object> get props => [
    id ?? '',
    uid ?? 0,
    vehicleType ?? '',
  ];
}