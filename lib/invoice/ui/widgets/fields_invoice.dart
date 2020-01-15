import 'package:car_wash_app/invoice/ui/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FieldsInvoice extends StatefulWidget {
  final textPlaca;
  final textClient;
  final textEmail;
  final textPhoneNumber;
  bool sendEmail = false;
  VoidCallback finalEditPlaca;
  final bool enableForm;
  final bool validatePlaca;
  final focusClient;
  final autofocusPlaca;
  final editForm;

  FieldsInvoice({
    Key key,
    this.textPlaca,
    this.sendEmail,
    this.textClient,
    this.textEmail,
    this.textPhoneNumber,
    this.finalEditPlaca,
    this.enableForm,
    this.validatePlaca,
    this.focusClient,
    this.autofocusPlaca,
    this.editForm,
  });

  @override
  State<StatefulWidget> createState() {
    return _FieldsInvoice();
  }
}

class _FieldsInvoice extends State<FieldsInvoice> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        //Regular expression para dejar pasar solo letras y numeros
        TextFieldInput(
          enable: widget.editForm,
          labelText: "Placa",
          textController: widget.textPlaca,
          isUpperCase: true,
          textInputFormatter: [
            WhitelistingTextInputFormatter(RegExp("^[a-zA-Z0-9]*"))
          ],
          onFinalEditText: widget.finalEditPlaca,
          validate: widget.validatePlaca,
          textValidate: 'El Campo no puede estar vacio',
          autofocus: widget.autofocusPlaca,
        ),
        SizedBox(
          height: 9,
        ),
        TextFieldInput(
          labelText: "Cliente",
          textController: widget.textClient,
          enable: widget.enableForm,
          focusNode: widget.focusClient,
        ),
        SizedBox(
          height: 9,
        ),
        TextFieldInput(
          labelText: "Telefono",
          textController: widget.textPhoneNumber,
          inputType: TextInputType.number,
          enable: widget.enableForm,
        ),
        SizedBox(
          height: 9,
        ),
        TextFieldInput(
          labelText: "Correo Electrónico",
          textController: widget.textEmail,
          inputType: TextInputType.emailAddress,
          enable: widget.enableForm,
        ),
        SizedBox(
          height: 9,
        ),
        SizedBox(
          height: 9,
        ),
        Row(
          children: <Widget>[
            Checkbox(
              value: widget.sendEmail,
              onChanged: widget.enableForm ? (bool value) {
                setState(() {
                  widget.sendEmail = value;
                });
              } : null,
              checkColor: Colors.white,
              activeColor: Color(0xFF59B258),
            ),
            Text(
              "Enviar por whatsapp",
              style: TextStyle(
                fontFamily: "Lato",
                decoration: TextDecoration.none,
                color: Color(0xFFAEAEAE),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
