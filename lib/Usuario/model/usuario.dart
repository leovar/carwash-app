import 'package:flutter/material.dart';

class Usuario {
  final String nombre;
  final String email;
  final String photoUrl;

  Usuario(
      {Key key, @required this.nombre, @required this.email, this.photoUrl});
}
