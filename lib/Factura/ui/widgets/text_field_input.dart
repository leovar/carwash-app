import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {

  final String _labelText;

  TextFieldInput(this._labelText);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextField(
      maxLines: 1,
      cursorColor: Colors.white,
      style: TextStyle(
        fontFamily: "Lato",
        decoration: TextDecoration.none,
        color: Color(0xFFAEAEAE),
        fontSize: 18,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 17, horizontal: 15),
        labelText: _labelText,
        labelStyle: TextStyle(
          decoration: TextDecoration.none,
          fontFamily: "Lato",
          color: Color(0xFFAEAEAE),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Color(0xFFAEAEAE),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: Color(0xFFAEAEAE),
          ),
        ),
      ),
    );
  }
}