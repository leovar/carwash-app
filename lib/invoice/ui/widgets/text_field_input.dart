import 'package:flutter/material.dart';

class TextFieldInput extends StatefulWidget {

  final String _labelText;
  final textController;

  TextFieldInput(this._labelText,
        this.textController,
      );

  @override
  State<StatefulWidget> createState() {
    return _TextFieldInput();
  }
}

class _TextFieldInput extends State<TextFieldInput> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.textController,
      maxLines: 1,
      autofocus: false,
      cursorColor: Colors.white,
      style: TextStyle(
        fontFamily: "Lato",
        decoration: TextDecoration.none,
        color: Color(0xFFAEAEAE),
        fontSize: 18,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 17, horizontal: 15),
        labelText: widget._labelText,
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