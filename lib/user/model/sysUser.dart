import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class SysUser extends Equatable {
  final String? id;
  final String uid;
  final String name;
  final String email;
  final String companyId;
  String? photoUrl;
  final Timestamp? lastSignIn;
  final bool? active;
  final List<DocumentReference>? locations;
  final bool? isAdministrator;
  final bool? isCoordinator;
  final bool? isOperator;
  final double? operatorCommission;
  bool? isSelected;


  SysUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.companyId,
    this.id,
    this.photoUrl,
    this.lastSignIn,
    this.active,
    this.locations,
    this.isAdministrator,
    this.isCoordinator,
    this.isOperator,
    this.isSelected,
    this.operatorCommission,
  });

  factory SysUser.fromJson(Map<String, dynamic> json, {required String id}) {
    List<DocumentReference> operatorsListDb = <DocumentReference>[];
    List operatorsList = json['locations']??[];
    operatorsList.forEach((drLocation) {
      operatorsListDb.add(drLocation);
    });

    return SysUser(
      id: id ?? '',
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      lastSignIn: json['lastSignIn'],
      active: json['active'],
      locations: operatorsListDb,
      isAdministrator: json['isAdministrator'],
      isCoordinator: json['isCoordinator'],
      isOperator: json['isOperator'],
      isSelected: false,
      companyId: json['companyId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': this.uid,
      'name': this.name,
      'email': this.email,
      'photoUrl': this.photoUrl,
      'lastSignIn': DateTime.now(),
      'active': this.active,
      'locations': this.locations,
      'isAdministrator': this.isAdministrator,
      'isCoordinator': this.isCoordinator,
      'isOperator': this.isOperator,
      'companyId': this.companyId,
    };
  }

  Map<String, dynamic> toJsonUpdateCompany() {
    return {
      'uid': this.uid,
      'name': this.name,
      'email': this.email,
      'photoUrl': this.photoUrl,
      'lastSignIn': this.lastSignIn,
      'active': this.active,
      'locations': this.locations,
      'isAdministrator': this.isAdministrator,
      'isCoordinator': this.isCoordinator,
      'isOperator': this.isOperator,
      'companyId': this.companyId,
    };
  }

  factory SysUser.copyWith({
    required SysUser origin,
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    Timestamp? lastSignIn,
    bool? isSelected,
    String? companyId,
  }) {
    return SysUser(
      id: origin.id,
      uid: uid ?? origin.uid,
      active: origin.active,
      name: name ?? origin.name,
      email: email ?? origin.email,
      photoUrl: photoUrl ?? origin.photoUrl,
      lastSignIn: lastSignIn ?? origin.lastSignIn,
      isAdministrator: origin.isAdministrator,
      isCoordinator: origin.isCoordinator,
      isOperator: origin.isOperator,
      isSelected: isSelected ?? origin.isSelected,
      locations: origin.locations,
      companyId: companyId ?? origin.companyId,
    );
  }

  factory SysUser.copyUserOperatorToSaveInvoice({
    String? id,
    required String name,
    double? operatorCommission,
    required String companyId,
  }) {
    return SysUser(id: id, name: name, companyId: companyId , operatorCommission: operatorCommission, uid: '', email: '');
  }

  factory SysUser.fromJsonOperatorIntoInvoice(Map<dynamic, dynamic> json) {
    return SysUser(
      id: json['id'],
      name: json['name'],
      operatorCommission: json['operatorCommission'],
      companyId: '',
      isSelected: true,
      uid: '',
      email: '',
    );
  }

  static Map<String, dynamic> toJsonInvoiceOperator(
    String? userId,
    String name,
    double? operatorCommission,
  ) {
    return {
      'id': userId,
      'name': name,
      'operatorCommission': operatorCommission,
    };
  }

  @override
  List<Object> get props => [
    id ?? '',
    uid ?? '',
    name ?? '',
    email ?? '',
    photoUrl ?? '',
    lastSignIn ?? DateTime.timestamp(),
    active ?? false,
    locations ?? FirebaseFirestore.instance.collection('locations').doc('defaultDocId'),
    isAdministrator ?? false,
    isCoordinator ?? false,
    isOperator ?? false,
    isSelected ?? false,
    operatorCommission ?? 0,
    companyId,
  ];
}
