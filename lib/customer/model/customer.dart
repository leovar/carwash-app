
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

  Customer({
    this.id,
    this.name,
    this.address,
    this.phoneNumber,
    this.email,
    this.creationDate,
  });

  @override
  List<Object> get props => [
    id,
    name,
    address,
    phoneNumber,
    email,
    creationDate,
  ];
}