import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class User extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final Timestamp lastSignIn;
  final bool active;
  final List<DocumentReference> locations;
  final bool isAdministrator;
  final bool isCoordinator;
  final bool isOperator;

  User({
    @required this.uid,
    @required this.name,
    @required this.email,
    this.photoUrl,
    this.lastSignIn,
    this.active,
    this.locations,
    this.isAdministrator,
    this.isCoordinator,
    this.isOperator,
  });

  factory User.fromJson(Map<String, dynamic> json, {String id}) {
    return User(
      uid: id,
      name: json['name'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      lastSignIn: json['lastSignIn'],
      active: json['active'],
      locations: json['locations'],
      isAdministrator: json['isAdministrator'],
      isCoordinator: json['isCoordinator'],
      isOperator: json['isOperator'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': this.uid,
      'name': this.name,
      'email' : this.email,
      'photoUrl' : this.photoUrl,
      'lastSignIn' : DateTime.now(),
      'active' : this.active,
      'locations' : this.locations,
      'isAdministrator' : this.isAdministrator,
      'isCoordinator' : this.isCoordinator,
      'isOperator' : this.isOperator,
    };
  }

  factory User.copyWith({
    @required User origin,
    String uid,
    String name,
    String email,
    String photoUrl,
    Timestamp lastSignIn,
  }) {
    return User(
      uid: uid ?? origin.uid,
      name: name ?? origin.name,
      email: email ?? origin.email,
      photoUrl: photoUrl ?? origin.photoUrl,
      lastSignIn: lastSignIn ?? origin.lastSignIn,
      isAdministrator: origin.isAdministrator,
      isCoordinator: origin.isCoordinator,
      isOperator: origin.isOperator,
    );
  }

  @override
  List<Object> get props => [
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
  ];
}