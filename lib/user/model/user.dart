import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class User extends Equatable {
  final String id;
  final String uid;
  final String name;
  final String email;
  String photoUrl;
  final Timestamp lastSignIn;
  final bool active;
  final List<DocumentReference> locations;
  final bool isAdministrator;
  final bool isCoordinator;
  final bool isOperator;
  final double operatorCommission;
  bool isSelected;

  User({
    @required this.uid,
    @required this.name,
    @required this.email,
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

  factory User.fromJson(Map<String, dynamic> json, {String id}) {
    List<DocumentReference> operatorsListDb = <DocumentReference>[];
    List operatorsList = json['locations'];
    operatorsList?.forEach((drLocation) {
      operatorsListDb.add(drLocation);
    });

    return User(
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
    };
  }

  factory User.copyWith({
    @required User origin,
    String uid,
    String name,
    String email,
    String photoUrl,
    Timestamp lastSignIn,
    bool isSelected,
  }) {
    return User(
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
    );
  }

  factory User.copyUserOperatorToSaveInvoice({String id, String name, double operatorCommission}) {
    return User(
      id: id,
      name: name,
      operatorCommission: operatorCommission,
    );
  }

  factory User.fromJsonOperatorIntoInvoice(Map<dynamic, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      operatorCommission: json['operatorCommission'],
      isSelected: true,
    );
  }

  Map<String, dynamic> toJsonInvoiceOperator(
      String userId,
      String name,
      double operatorCommission,
      ) {
    return {
      'id': userId,
      'name': name,
      'operatorCommission': operatorCommission,
    };
  }

  @override
  List<Object> get props => [
        id,
        uid,
        name,
        email,
        photoUrl,
        lastSignIn,
        active,
        locations,
        isAdministrator,
        isCoordinator,
        isOperator,
        isSelected,
        operatorCommission,
      ];
}
