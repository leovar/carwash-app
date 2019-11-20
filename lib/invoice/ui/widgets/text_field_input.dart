import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldInput extends StatefulWidget {
  final String labelText;
  final textController;
  final TextInputType inputType;
  final textInputFormatter;
  final focusNode;
  final bool isUpperCase;
  final VoidCallback onFinalEditText;
  final bool enable;
  final bool validate;
  final String textValidate;
  final bool autofocus;
  final int maxLength;
  final int maxLines;
  final bool isPassword;

  TextFieldInput({
    Key key,
    this.labelText,
    this.textController,
    this.onFinalEditText,
    this.textValidate,
    this.focusNode = null,
    this.inputType = null,
    this.textInputFormatter = null,
    this.isUpperCase = false,
    this.enable = true,
    this.validate = false,
    this.autofocus = false,
    this.maxLength,
    this.maxLines = 1,
    this.isPassword = false,
  });

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
      maxLines: widget.maxLines,
      obscureText: widget.isPassword,
      maxLength: widget.maxLength ?? null,
      autofocus: widget.autofocus ?? false,
      focusNode: widget.focusNode,
      keyboardType: widget.inputType ?? null,
      inputFormatters: widget.textInputFormatter ?? null,
      textCapitalization: widget.isUpperCase ?? false
          ? TextCapitalization.characters
          : TextCapitalization.sentences,
      cursorColor: Color(0xFFAEAEAE),
      onChanged: (value) {
        widget.onFinalEditText();
      },
      enabled: widget.enable ?? true,
      style: TextStyle(
        fontFamily: "Lato",
        decoration: TextDecoration.none,
        color: Color(0xFFAEAEAE),
        fontSize: 18,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 17, horizontal: 15),
        labelText: widget.labelText,
        errorText: widget.validate ? widget.textValidate : null,
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
