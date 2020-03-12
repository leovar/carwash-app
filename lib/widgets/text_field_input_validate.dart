import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldInputValidate extends StatefulWidget {
  final String labelText;
  final textController;
  final TextInputType inputType;
  final textInputFormatter;
  final focusNode;
  final bool isUpperCase;
  final VoidCallback onFinalEditText;
  final bool enable;
  final int validateType;
  final bool autofocus;
  final int maxLength;
  final int maxLines;
  final bool isPassword;
  final Color colorText;

  TextFieldInputValidate({
    Key key,
    this.labelText,
    this.textController,
    this.onFinalEditText,
    this.focusNode = null,
    this.inputType = null,
    this.textInputFormatter = null,
    this.isUpperCase = false,
    this.enable = true,
    this.autofocus = false,
    this.maxLength,
    this.maxLines = 1,
    this.isPassword = false,
    this.colorText,
    this.validateType,
  });

  @override
  State<StatefulWidget> createState() {
    return _TextFieldInputColorValidate();
  }
}

class _TextFieldInputColorValidate extends State<TextFieldInputValidate> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
      cursorColor: widget.colorText ?? Color(0xFFAEAEAE),
      onChanged: (value) {
        widget.onFinalEditText();
      },
      validator: (String args) {
        return this._validateField(args);
      },
      enabled: widget.enable ?? true,
      style: TextStyle(
        fontFamily: "Lato",
        decoration: TextDecoration.none,
        color: widget.colorText ?? Color(0xFFAEAEAE),
        fontSize: 18,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 17, horizontal: 15),
        labelText: widget.labelText,
        //errorText: widget.validate ? widget.textValidate : null,
        labelStyle: TextStyle(
          decoration: TextDecoration.none,
          fontFamily: "Lato",
          color: widget.colorText ?? Color(0xFFAEAEAE),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.colorText ?? Color(0xFFAEAEAE),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: widget.colorText ?? Color(0xFFAEAEAE),
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: widget.colorText ?? Color(0xFFAEAEAE),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: widget.colorText ?? Color(0xFFAEAEAE),
          ),
        ),
      ),
    );
  }

  String _validateField(String args) {
    switch (widget.validateType ?? 0) {
      case 1:
        {
          //Email validation
          bool emailValid = RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(args);
          if (!emailValid)
            return 'El correo no es valido';
          else
            return null;
        }
        break;

      case 2:
        {
          if (args.isEmpty)
            return 'El nombre no puede estar vacio';
          else
            return null;
        }
        break;

      case 3:
        {
          if (args.isEmpty)
            return 'El telefono no puede estar vacio';
          else if (args.length < 10)
            return 'El telefono debe contener 10 caracteres';
          return null;
        }
        break;
    }
    return '';
  }
}
