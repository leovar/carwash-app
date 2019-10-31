import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Customer extends Equatable {
  final String id;
  final String name;
  final String address;
  final String phoneNumber;
  final String email;
  final Timestamp creationDate;
  final List<DocumentReference> vehicles;

  Customer({
    this.id,
    this.name,
    this.address,
    this.phoneNumber,
    this.email,
    this.creationDate,
    this.vehicles,
  });

  factory Customer.fromJson(Map<String, dynamic> json, {String id}) {
    List<DocumentReference> vehiclesListDb = <DocumentReference>[];
    List vehiclesList = json['vehicles'];
    vehiclesList?.forEach((drLocation) {
      vehiclesListDb.add(drLocation);
    });

    return Customer(
      id: id,
      name: json['name'],
      address: json['address'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      creationDate: json['creationDate'],
      vehicles: vehiclesListDb,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'address': this.address,
      'phoneNumber': this.phoneNumber,
      'email': this.email,
      'creationDate': this.creationDate,
      'vehicles': this.vehicles,
    };
  }

  @override
  List<Object> get props => [
        id,
        name,
        address,
        phoneNumber,
        email,
        creationDate,
        vehicles,
      ];
}
