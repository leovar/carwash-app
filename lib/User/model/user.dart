import 'package:flutter/material.dart';

class User {
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
}
