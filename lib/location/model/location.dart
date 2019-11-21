import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Location extends Equatable {
  final String id;
  final String locationName;
  final String address;
  final String nit;
  final String prefix;
  final String dianResolution;
  final int initConcec;
  final int finalConsec;
  final Timestamp creationDate;
  final bool active;
  bool isSelected;

  Location({
    this.id,
    this.locationName,
    this.address,
    this.nit,
    this.prefix,
    this.dianResolution,
    this.initConcec,
    this.finalConsec,
    this.creationDate,
    this.isSelected,
    this.active
  });

  factory Location.fromJson(Map<String, dynamic> json, {String id}) {
    return Location(
      id: id,
      locationName: json['locationName'],
      address: json['address'],
      nit: json['nit'],
      prefix: json['prefix'],
      dianResolution: json['dianResolution'],
      initConcec: json['initConcec'],
      finalConsec: json['finalConsec'],
      creationDate: json['creationDate'],
      active: json['active'],
      isSelected: false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationName': this.locationName,
      'address': this.address,
      'nit' : this.nit,
      'prefix' : this.prefix,
      'dianResolution' : this.dianResolution,
      'initConcec' : this.initConcec,
      'finalConsec' : this.finalConsec,
      'creationDate' : Timestamp.now(),
      'active' : this.active,
    };
  }


  @override
  List<Object> get props => [
    id,
    locationName,
    address,
    nit,
    prefix,
    dianResolution,
    initConcec,
    finalConsec,
    creationDate,
    active,
  ];
}
