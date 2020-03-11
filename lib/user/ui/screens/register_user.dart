import 'package:car_wash_app/invoice/ui/widgets/text_field_input.dart';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/widgets/gradient_back.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:intl/intl.dart';

class RegisterUser extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterUser();
}

class _RegisterUser extends State<RegisterUser> {
  UserBloc _userBloc;

  final _textEmail = TextEditingController();
  final _textPassword = TextEditingController();
  final _textUserName = TextEditingController();
  final _textPhone = TextEditingController();
  final _textNeighborhood = TextEditingController();
  final _textBirthDate = TextEditingController();
  final _textPlaca = TextEditingController();

  bool _obscureText = true;
  DateTime _date = new DateTime.now();

  @override
  void initState() {
    super.initState();
    this.clearData();
  }

  @override
  void dispose() {
    super.dispose();
    _userBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _userBloc = BlocProvider.of(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            GradientBack(),
            bodyContainer(),
          ],
        ),
      ),
    );
  }

  Widget bodyContainer() {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 16),
                height: 65,
                child: Center(
                  child: Text(
                    'REGISTRATE',
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              TextFieldInput(
                labelText: "Correo Electrónico",
                textController: _textEmail,
                inputType: TextInputType.emailAddress,
                enable: true,
                autofocus: false,
                colorText: Colors.white,
              ),
              SizedBox(height: 16),
              this._inputTextPassword(),
              SizedBox(height: 16),
              TextFieldInput(
                labelText: "Nombre",
                textController: _textUserName,
                maxLines: 1,
                colorText: Colors.white,
              ),
              SizedBox(height: 16),
              TextFieldInput(
                labelText: "Telefono",
                textController: _textPhone,
                inputType: TextInputType.number,
                autofocus: false,
                maxLength: 10,
                colorText: Colors.white,
              ),
              SizedBox(height: 16),
              TextFieldInput(
                labelText: "Barrio",
                textController: _textNeighborhood,
                maxLines: 1,
                colorText: Colors.white,
              ),
              SizedBox(height: 16),
              TextFieldInput(
                labelText: "Fecha de Nacimiento - (dd/mm/aaaa)",
                textController: _textBirthDate,
                colorText: Colors.white,
                hintText: 'dd/mm/aaaa',
                inputType: TextInputType.datetime,
                textInputFormatter: [
                  WhitelistingTextInputFormatter(
                      RegExp('^[0-9]*\/*[0-9]*\/*[0-9]*'))
                ],
                onFinalEditText: _onChangeTextBirthDate,
              ),
              SizedBox(height: 16),
              TextFieldInput(
                labelText: "Placa",
                textController: _textPlaca,
                isUpperCase: true,
                textInputFormatter: [
                  WhitelistingTextInputFormatter(RegExp("^[a-zA-Z0-9]*"))
                ],
                colorText: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputTextPassword() {
    return TextField(
      controller: _textPassword,
      maxLines: 1,
      obscureText: _obscureText,
      cursorColor: Colors.white,
      style: TextStyle(
        fontFamily: "Lato",
        decoration: TextDecoration.none,
        color: Colors.white,
        fontSize: 18,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 17, horizontal: 15),
        labelText: 'Contraseña',
        labelStyle: TextStyle(
          decoration: TextDecoration.none,
          fontFamily: "Lato",
          color: Colors.white,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.white,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: Colors.white,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Colors.white,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Colors.white,
          ),
        ),
        suffixIcon: InkWell(
          onTap: () => this._togglePassword(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: _obscureText
                ? Icon(
                    Icons.visibility,
                    color: Colors.white,
                  )
                : Icon(
                    Icons.visibility_off,
                    color: Colors.white,
                  ),
          ),
        ),
      ),
    );
  }

  /// Functions

  void _onChangeTextBirthDate() {
    var text = _textBirthDate.text;
    var val = _textBirthDate.text.split('/');
    var val1 = int.tryParse(val[0]??0);
    var val2 = int.tryParse(val.length > 1 ? val[1] : '0');
    var val3 = int.tryParse(val.length > 2 ? val[2] : '0');

    if (text.length > 0 && text.length < 3) {
      _textBirthDate.text = val1.toString();
      _textBirthDate.selection = TextSelection.fromPosition(TextPosition(offset: _textBirthDate.text.length));
    } else if (text.length > 2 && text.length < 4) {
      _textBirthDate.text = text.substring(0,2) + '/' + text.substring(2, text.length);
      _textBirthDate.selection = TextSelection.fromPosition(TextPosition(offset: _textBirthDate.text.length));
    } else if (text.length > 5 && text.length < 7) {
      _textBirthDate.text = text.substring(0,5) + '/' + text.substring(5, text.length);
      _textBirthDate.selection = TextSelection.fromPosition(TextPosition(offset: _textBirthDate.text.length));
    }


    if (val1 > 0 && val1 < 10) {  //first number
      if (text.length > 1) {
        //_textBirthDate.text = text.substring(0,1) + '/' + text.substring(1, text.length);
        //_textBirthDate.selection = TextSelection.fromPosition(TextPosition(offset: _textBirthDate.text.length));
      } else {

      }
    } else if (val1 > 9 && val1 < 32) {

    } else { //second number
      //message de day not superate 31 days
    }



  }

  void clearData() {
    _textEmail.text = '';
    _textPassword.text = '';
    _textUserName.text = '';
    _textPhone.text = '';
    _textNeighborhood.text = '';
    _textBirthDate.text = '';
    _textPlaca.text = '';
  }

  // Toggles the password show status
  void _togglePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

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
        _textBirthDate.value =
            TextEditingValue(text: formatDate.format(picked));
      });
  }
}
