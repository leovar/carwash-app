import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class User extends Equatable {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;

  User({
    @required this.uid,
    Key key,
    @required this.name,
    @required this.email,
    this.photoUrl,
  });

  @override
  List<Object> get props => [
    uid,
    name,
    email,
    photoUrl
  ];
}
