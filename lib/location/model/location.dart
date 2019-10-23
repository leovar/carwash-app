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
  });

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
  ];
}
