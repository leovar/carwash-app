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
  final Function(bool) cbHandlerSendEmail;
  VoidCallback finalEditPlaca;
  final bool enableForm;
  final bool validatePlaca;
  final focusClient;
  final autofocusPlaca;
  final editForm;

  FieldsInvoice({
    Key? key,
    this.textPlaca,
    required this.sendEmail,
    required this.cbHandlerSendEmail,
    this.textClient,
    this.textEmail,
    this.textPhoneNumber,
    this.textNeighborhood,
    this.textBirthDate,
    this.textTimeDelivery,
    required this.finalEditPlaca,
    required this.enableForm,
    required this.validatePlaca,
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
  bool _sendEmail = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _sendEmail = widget.sendEmail;
    });
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
            FilteringTextInputFormatter.allow(RegExp("^[a-zA-Z0-9]*")),
            UpperCaseTextFormatter(),
          ],
          onFinalEditText: widget.finalEditPlaca,
          validate: widget.validatePlaca,
          textValidate: 'El Campo no puede estar vacio',
          autofocus: widget.autofocusPlaca,
        ),
        SizedBox(height: 9),
        TextFieldInput(
          labelText: "Cliente",
          textController: widget.textClient,
          enable: widget.enableForm,
          focusNode: widget.focusClient,
        ),
        SizedBox(height: 9),
        TextFieldInput(
          labelText: "Telefono",
          textController: widget.textPhoneNumber,
          inputType: TextInputType.number,
          enable: widget.enableForm,
          autofocus: false,
          maxLength: 10,
        ),
        SizedBox(height: 9),
        TextFieldInput(
          labelText: "Correo Electrónico",
          textController: widget.textEmail,
          inputType: TextInputType.emailAddress,
          //enable: widget.enableForm,
          autofocus: false,
        ),
        SizedBox(height: 9),
        TextFieldInput(
          labelText: "Barrio",
          textController: widget.textNeighborhood,
          enable: widget.enableForm,
          autofocus: false,
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
              autofocus: false,
            ),
          ),
        ),
        SizedBox(height: 9),
        GestureDetector(
          onTap: widget.enableForm ? () => _selectTime(context) : null,
          child: AbsorbPointer(
            child: TextFieldInput(
              labelText: "Hora Estimada de Entrega",
              textController: widget.textTimeDelivery,
              inputType: TextInputType.datetime,
              enable: widget.enableForm,
              autofocus: false,
            ),
          ),
        ),
        SizedBox(height: 9),
        Row(
          children: <Widget>[
            Checkbox(
              value: _sendEmail,
              onChanged:
                  true //widget.enableForm
                      ? (bool? value) {
                        if (value != null) {
                          setState(() {
                            _sendEmail = value;
                          });
                          widget.cbHandlerSendEmail(value);
                        }
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      locale: myLocale,
      firstDate: DateTime(1901, 1),
      lastDate: DateTime(2100),
    );
    if (picked != _date)
      setState(() {
        if (picked != null) {
          _date = picked;
          widget.textBirthDate.value = TextEditingValue(
            text: formatDate.format(picked),
          );
        }
      });
  }

  Future<Null> _selectTime(BuildContext context) async {
    String text12Hour = '';
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != _time)
      setState(() {
        _time = picked;

        final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
        final minute = picked.minute.toString().padLeft(2, '0');
        final period = picked.period == DayPeriod.am ? 'A.M' : 'P.M';

        text12Hour = '$hour:$minute $period';
        widget.textTimeDelivery.value = TextEditingValue(text: text12Hour);
      });
  }
}

// Custom Formatter to force uppercase input
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
    );
  }
}
