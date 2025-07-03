import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Location extends Equatable {
  final String? id;
  final String? locationName;
  final String? address;
  final String? phoneNumber;
  final String? director;
  final String? nit;
  final String? regimen;
  final String? prefix;
  final String? dianResolution;
  final int? initConcec;
  final int? finalConsec;
  final Timestamp? creationDate;
  final bool? active;
  final bool? sendMessageSms;
  final bool? sendMessageWp;
  final bool? printIva;
  bool? isSelected;
  int? activeCells;
  final int? totalCells;

  Location({
    this.id,
    this.locationName,
    this.address,
    this.phoneNumber,
    this.director,
    this.nit,
    this.regimen,
    this.prefix,
    this.dianResolution,
    this.initConcec,
    this.finalConsec,
    this.creationDate,
    this.isSelected,
    this.active,
    this.sendMessageSms,
    this.sendMessageWp,
    this.printIva,
    this.activeCells,
    this.totalCells,
  });

  factory Location.fromJson(Map<String, dynamic> json, {String? id}) {
    return Location(
        id: id,
        locationName: json['locationName'],
        address: json['address'],
        phoneNumber: json['phoneNumber'],
        director: json['director'],
        nit: json['nit'],
        regimen: json['regimen'],
        prefix: json['prefix'],
        dianResolution: json['dianResolution'],
        initConcec: json['initConcec'],
        finalConsec: json['finalConsec'],
        creationDate: json['creationDate'],
        active: json['active'],
        sendMessageSms: json['sendMessageSms'],
        sendMessageWp: json['sendMessageWp'],
        printIva: json['printIva'],
        isSelected: false,
        activeCells: json['activeCells'],
        totalCells: json['totalCells'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locationName': this.locationName,
      'address': this.address,
      'phoneNumber': this.phoneNumber,
      'director': this.director,
      'nit': this.nit,
      'regimen': this.regimen,
      'prefix': this.prefix,
      'dianResolution': this.dianResolution,
      'initConcec': this.initConcec,
      'finalConsec': this.finalConsec,
      'creationDate': this.creationDate,
      'active': this.active,
      'sendMessageSms': this.sendMessageSms,
      'sendMessageWp': this.sendMessageWp,
      'printIva': this.printIva,
      'activeCells': this.activeCells,
      'totalCells': this.totalCells,
    };
  }

  factory Location.copyWith({
    required Location origin,
    int? activeCells
  }) {
    return Location(
      id: origin.id,
      locationName: origin.locationName,
      address: origin.address,
      phoneNumber: origin.phoneNumber,
      director: origin.director,
      nit: origin.nit,
      regimen: origin.regimen,
      prefix: origin.prefix,
      dianResolution: origin.dianResolution,
      initConcec: origin.initConcec,
      finalConsec: origin.finalConsec,
      creationDate: origin.creationDate,
      active: origin.active,
      sendMessageSms: origin.sendMessageSms,
      sendMessageWp: origin.sendMessageWp,
      printIva: origin.printIva,
      isSelected: origin.isSelected,
      activeCells: activeCells ?? origin.activeCells,
      totalCells: origin.totalCells,
    );
  }


  @override
  List<Object> get props => [
        id ?? '',
        locationName ?? '',
        address ?? '',
        phoneNumber ?? '',
        director ?? '',
        nit ?? '',
        regimen ?? '',
        prefix ?? '',
        dianResolution ?? '',
        initConcec ?? 0,
        finalConsec ?? 0,
        creationDate ?? new DateTime.timestamp(),
        active ?? false,
        sendMessageSms ?? false,
        sendMessageWp ?? false,
        printIva ?? false,
        activeCells ?? 0,
        totalCells ?? 0,
      ];
}
