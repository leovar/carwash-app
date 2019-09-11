import 'package:flutter/material.dart';

class HeaderLogin extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 87,
      decoration: BoxDecoration(
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage("assets/images/car_wash_movil_logo_blanco.png"),
        ),
        shape:BoxShape.rectangle
      ),
    );
  }
}