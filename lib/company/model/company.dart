import 'dart:ffi';

import 'package:car_wash_app/company/model/contact_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class Company extends Equatable {
  final String? Id;
  final bool active;
  final String? address;
  final String city;
  final int companyCode;
  final String companyName;
  final String contactName;
  final List<ContactUser>? contactUsers;
  final String country;
  final Timestamp creationDate;
  final String? email;
  final Timestamp endDate;
  final int licenseMonths;
  final String licenseType;
  final int licenseTypeCode;
  final String? mainCompany;
  final String nit;
  final String phone;
  final Timestamp startDate;
  final String region;

  Company({
    this.Id,
    required this.active,
    this.address,
    required this.city,
    required this.companyCode,
    required this.companyName,
    required this.contactName,
    this.contactUsers,
    required this.country,
    required this.creationDate,
    this.email,
    required this.endDate,
    required this.licenseMonths,
    required this.licenseType,
    required this.licenseTypeCode,
    this.mainCompany,
    required this.nit,
    required this.phone,
    required this.startDate,
    required this.region
});

  factory Company.fromJson(Map<String, dynamic> json, {required String id}) {
    List<ContactUser> contactListDb = <ContactUser>[];
    var contactsList = json['contactUsers']??[];
    contactsList?.forEach((drContact) {
      ContactUser cu = ContactUser.fromJson(drContact);
      contactListDb.add(cu);
    });

    return Company(
      Id: id,
      active: json['active'],
      address: json['address'],
      city: json['city'],
      companyCode: json['companyCode'],
      companyName: json['companyName'],
      contactName: json['contactName'],
      contactUsers: contactListDb,
      country: json['country'],
      creationDate: json['creationDate'],
      email: json['email'],
      endDate: json['endDate'],
      licenseMonths: json['licenseMonths'],
      licenseType: json['licenseType'],
      licenseTypeCode: json['licenseTypeCode'],
      mainCompany: json['mainCompany'],
      nit: json['nit'],
      phone: json['phone'],
      startDate: json['startDate'],
      region: json['region'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'active': this.active,
      'address': this.address,
      'city': this.city,
      'companyCode': this.companyCode,
      'companyName': this.companyName,
      'contactName': this.contactName,
      'country': this.country,
      'creationDate': this.creationDate,
      'email': this.email,
      'endDate': this.endDate,
      'licenseMonths': this.licenseMonths,
      'licenseType': this.licenseType,
      'licenseTypeCode': this.licenseTypeCode,
      'mainCompany': this.mainCompany,
      'nit': this.nit,
      'phone': this.phone,
      'startDate': this.startDate,
      'region': this.region,
    };
  }

  factory Company.copyWith({
    required Company origin,
    String? companyName,
    String? contactName,
    String? email,
    String? phone,
    String? nit,
    String? address,
    String? region,
    String? city,
    List<ContactUser>? contactsList,
  }) {
    return Company(
      Id: origin.Id,
      active: origin.active,
      city: city ?? origin.city,
      address: address ?? origin.address,
      companyCode: origin.companyCode,
      companyName: companyName ?? origin.companyName,
      contactName: contactName ?? origin.contactName,
      contactUsers: contactsList ?? origin.contactUsers,
      country: origin.country,
      creationDate: origin.creationDate,
      email: email ?? origin.email,
      endDate: origin.endDate,
      licenseMonths: origin.licenseMonths,
      licenseType: origin.licenseType,
      licenseTypeCode: origin.licenseTypeCode,
      mainCompany: origin.mainCompany,
      nit: nit ?? origin.nit,
      phone: phone ?? origin.phone,
      startDate: origin.startDate,
      region: region ?? origin.region,
    );
  }


  @override
  List<Object?> get props => [
    Id ?? '',
    active,
    address ?? '',
    city,
    companyCode,
    companyName,
    contactName,
    contactUsers ?? [],
    country,
    creationDate,
    email,
    endDate,
    licenseMonths,
    licenseType,
    licenseTypeCode,
    mainCompany,
    nit,
    phone,
    startDate,
    region,
  ];
}
