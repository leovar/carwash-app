import 'package:car_wash_app/invoice/ui/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FieldsInvoice extends StatefulWidget {
  final textPlaca;
  final textClient;
  final textEmail;
  final textPhoneNumber;
  final textNeighborhood;
  final textBirthDate;
  final textTimeDelivery;
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
    this.textNeighborhood,
    this.textBirthDate,
    this.textTimeDelivery,
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
  DateTime _date = new DateTime.now();
  TimeOfDay _time = new TimeOfDay.now();

  @override
  void initState() {
    super.initState();
  }

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
        TextFieldInput(
          labelText: "Barrio",
          textController: widget.textNeighborhood,
          enable: widget.enableForm,
        ),
        SizedBox(height: 9),
        GestureDetector(
          onTap: widget.enableForm ? () => _selectDate(context) : null,
          child: AbsorbPointer(
            child: TextFieldInput(
              labelText: "Fecha de Nacimiento",
              textController: widget.textBirthDate,
              inputType: TextInputType.datetime,
              enable: widget.enableForm,
            ),
          ),
        ),
        SizedBox(
          height: 9,
        ),
        GestureDetector(
          onTap: widget.enableForm ? () => _selectTime(context) : null,
          child: AbsorbPointer(
            child: TextFieldInput(
              labelText: "Hora Estimada de Entrega",
              textController: widget.textTimeDelivery,
              inputType: TextInputType.datetime,
              enable: widget.enableForm,
            ),
          ),
        ),
        SizedBox(
          height: 9,
        ),
        Row(
          children: <Widget>[
            Checkbox(
              value: widget.sendEmail,
              onChanged: widget.enableForm
                  ? (bool value) {
                      setState(() {
                        widget.sendEmail = value;
                      });
                    }
                  : null,
              checkColor: Colors.white,
              activeColor: Color(0xFF59B258),
            ),
            Text(
              "Enviar por correo electrónico",
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

  /// Functions

  Future<Null> _selectDate(BuildContext context) async {
    final formatDate = DateFormat.yMd('ES');
    Locale myLocale = Localizations.localeOf(context);
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _date,
        locale: myLocale,
        firstDate: DateTime(1901, 1),
        lastDate: DateTime(2100));
    if (picked != null && picked != _date)
      setState(() {
        _date = picked;
        widget.textBirthDate.value =
            TextEditingValue(text: formatDate.format(picked));
      });
  }

  Future<Null> _selectTime(BuildContext context) async {
    final formatTime = DateFormat.jm('ES');
    final MaterialLocalizations localizations = MaterialLocalizations.of(context);
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _time)
      setState(() {
        _time = picked;
        TimeOfDay elm = picked.replacing(hour: picked.hourOfPeriod);
        DateTime elm1 = DateFormat('dd/MM/yyyy hh:mm').parse('${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} ${picked.format(context)}');
        print(elm1);
        print(formatTime.format(elm1));
        widget.textTimeDelivery.value =
            TextEditingValue(text: picked.replacing(hour: picked.hourOfPeriod).format(context));
      });
  }
}
