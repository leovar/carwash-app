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
  final String birthDate;
  final String neighborhood;
  final String typeSex;

  Customer({
    this.id,
    this.name,
    this.address,
    this.phoneNumber,
    this.email,
    this.creationDate,
    this.vehicles,
    this.birthDate,
    this.neighborhood,
    this.typeSex,
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
      birthDate: json['birthDate'],
      neighborhood: json['neighborhood'],
      typeSex: json['typeSex'],
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
      'birthDate': this.birthDate,
      'neighborhood': this.neighborhood,
      'typeSex': this.typeSex,
    };
  }

  factory Customer.copyWith({
    @required Customer origin,
    String name,
    String address,
    String phoneNumber,
    String email,
    List<DocumentReference> vehicles,
  }) {
    return Customer(
      id: origin.id,
      name: name ?? origin.name,
      address: address ?? origin.address,
      phoneNumber: phoneNumber ?? origin.phoneNumber,
      email: email ?? origin.email,
      creationDate: origin.creationDate,
      vehicles: vehicles ?? origin.vehicles,
      birthDate: origin.birthDate,
      neighborhood: origin.neighborhood,
      typeSex: origin.typeSex,
    );
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
        birthDate,
        neighborhood,
        typeSex,
      ];
}
