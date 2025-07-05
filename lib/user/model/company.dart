import 'dart:ffi';

import 'package:car_wash_app/user/model/contact_user.dart';
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
  final List<ContactUser> contactUsers;
  final String country;
  final Timestamp creationDate;
  final Timestamp endDate;
  final int licenseMonths;
  final int licenseType;
  final String? mainCompany;
  final String companyName;
  final String nit;
  final Timestamp startDate;
  final String state;

  Company({
    this.Id,
    required this.active,
    this.address,
    required this.city,
    required this.companyCode,
    required this.contactUsers,
    required this.country,
    required this.creationDate,
    required this.endDate,
    required this.licenseMonths,
    required this.licenseType,
    this.mainCompany,
    required this.companyName,
    required this.nit,
    required this.startDate,
    required this.state
});



  @override
  List<Object?> get props => [
    Id ?? '',
    active,
    address ?? '',
    city,
    companyCode,
    contactUsers,
    country,
    creationDate,
    endDate,
    licenseMonths,
    licenseType,
    mainCompany,
    companyName,
    nit,
    startDate,
    state,
  ];
}
