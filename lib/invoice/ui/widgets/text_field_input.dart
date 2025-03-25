import 'package:flutter/material.dart';

class TextFieldInput extends StatefulWidget {
  final String labelText;
  final textController;
  final TextInputType? inputType;
  final textInputFormatter;
  final focusNode;
  final bool isUpperCase;
  final VoidCallback? onFinalEditText;
  final bool enable;
  final bool validate;
  final String? textValidate;
  final bool autofocus;
  final int? maxLength;
  final int maxLines;
  final bool isPassword;
  final Color? colorText;
  final String? hintText;

  TextFieldInput({
    Key? key,
    required this.labelText,
    this.textController,
    this.onFinalEditText,
    this.textValidate,
    this.focusNode = null,
    this.inputType,
    this.textInputFormatter = null,
    this.isUpperCase = false,
    this.enable = true,
    this.validate = false,
    this.autofocus = false,
    this.maxLength,
    this.maxLines = 1,
    this.isPassword = false,
    this.colorText,
    this.hintText,
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
      keyboardType: widget.inputType ?? TextInputType.text,
      inputFormatters: widget.textInputFormatter ?? null,
      textCapitalization: widget.isUpperCase ?? false
          ? TextCapitalization.characters
          : TextCapitalization.sentences,
      cursorColor: widget.colorText ?? Color(0xFFAEAEAE),
      onChanged: (value) {
        if (widget.onFinalEditText != null) {
          widget.onFinalEditText!();
        }
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
        errorText: widget.validate ? widget.textValidate : null,
        hintText: widget.hintText??null,
        hintStyle: TextStyle(
          decoration: TextDecoration.none,
          fontFamily: "Lato",
          color: widget.colorText ?? Color(0xFFAEAEAE),
        ),
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
}
