import 'package:flutter/material.dart';

class GradientBack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        colors: [Color(0xFF27AEBB), Color(0xFF59B258)],
        begin: Alignment.topCenter,
        //FractionalOffset(1.0, 0.0),
        end: Alignment.bottomCenter,
        //FractionalOffset(1.0, 0.8),
        stops: [0.0, 0.9],
        tileMode: TileMode.clamp,
      )),
    );
  }
}
