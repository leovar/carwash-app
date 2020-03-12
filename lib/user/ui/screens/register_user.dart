import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/ui/widgets/text_field_input.dart';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/widgets/gradient_back.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:car_wash_app/widgets/text_field_input_validate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _autoValidate = false;
  bool _obscureText = true;
  DateTime _date = new DateTime.now();
  String _oldTextBirthDay = '';

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
          child: Form(
            key: _formKey,
            autovalidate: _autoValidate,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                this.loginHeader(),
                SizedBox(height: 34),
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
                TextFieldInputValidate(
                  labelText: "Correo Electrónico",
                  textController: _textEmail,
                  inputType: TextInputType.emailAddress,
                  enable: true,
                  autofocus: false,
                  colorText: Colors.white,
                  validateType: 1,
                ),
                SizedBox(height: 16),
                this._inputTextPassword(),
                /*
                SizedBox(height: 16),
                TextFieldInputValidate(
                  labelText: "Nombre",
                  textController: _textUserName,
                  maxLines: 1,
                  colorText: Colors.white,
                  validateType: 2,
                ),
                SizedBox(height: 16),
                TextFieldInputValidate(
                  labelText: "Telefono",
                  textController: _textPhone,
                  inputType: TextInputType.number,
                  autofocus: false,
                  maxLength: 10,
                  colorText: Colors.white,
                  validateType: 3,
                ),
                SizedBox(height: 16),
                TextFieldInput(
                  labelText: "Barrio",
                  textController: _textNeighborhood,
                  maxLines: 1,
                  colorText: Colors.white,
                ),
                SizedBox(height: 16),

                 */
                //TextFieldInput(
                //  labelText: "Fecha de Nacimiento (dd/mm/aaaa)",
                //  textController: _textBirthDate,
                //  colorText: Colors.white,
                //  hintText: 'dd/mm/aaaa',
                //  inputType: TextInputType.datetime,
                  //textInputFormatter: [WhitelistingTextInputFormatter(RegExp('^[0-9]*\/*[0-9]*\/*[0-9]*'))],
                //  onFinalEditText: _onChangeTextBirthDate,
                //),
                //SizedBox(height: 16),
                //TextFieldInput(
                //  labelText: "Placa de su vehículo",
                //  textController: _textPlaca,
                //  isUpperCase: true,
                //  textInputFormatter: [
                    //WhitelistingTextInputFormatter(RegExp("^[a-zA-Z0-9]*"))
                //  ],
                //  colorText: Colors.white,
                //),
                SizedBox(height: 34),
                this._registerUserButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget loginHeader() {
    return Container(
      margin: EdgeInsets.only(top: 40),
      width: 250,
      height: 86,
      decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            image: AssetImage("assets/images/car_wash_movil_logo_blanco.png"),
          ),
          shape: BoxShape.rectangle),
    );
  }

  Widget _inputTextPassword() {
    return TextFormField(
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
      validator: (String args) {
        if (args.isEmpty)
          return 'El campo no puede estar vacio';
        else
          return null;
      },
    );
  }

  Widget _registerUserButton() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Material(
        child: InkWell(
          onTap: () {
            this._registerUser();
          },
          child: Container(
            width: 190.0,
            height: 42.0,
            child: Center(
              child: Text(
                'GUARDAR',
                style: TextStyle(
                  fontFamily: "Lato",
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        color: Colors.transparent,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(7.0),
      ),
    );
  }

  /// Functions

  void _onChangeTextBirthDate() {
    var text = _textBirthDate.text;
    var val = _textBirthDate.text.split('/');
    var val1 = int.tryParse(val[0] ?? 0);
    var val2 = int.tryParse(val.length > 1 ? val[1] : '0');
    var val3 = int.tryParse(val.length > 2 ? val[2] : '0');

    if (text.length > 10) {
      _textBirthDate.text = _oldTextBirthDay;
      _textBirthDate.selection = TextSelection.fromPosition(
          TextPosition(offset: _textBirthDate.text.length));
      return;
    }

    if (text.length > _oldTextBirthDay.length) {
      if (text.length > 2 && text.length < 4) {
        _textBirthDate.text =
            text.substring(0, 2) + '/' + text.substring(2, text.length);
        _textBirthDate.selection = TextSelection.fromPosition(
            TextPosition(offset: _textBirthDate.text.length));
      } else if (text.length > 5 && text.length < 7) {
        _textBirthDate.text =
            text.substring(0, 5) + '/' + text.substring(5, text.length);
        _textBirthDate.selection = TextSelection.fromPosition(
            TextPosition(offset: _textBirthDate.text.length));
      }

      if (val1 > 31 && val1.toString().length == 2) {
        MessagesUtils.showAlert(
                context: context,
                title: 'El dia no puede ser superior a 31',
                alertType: AlertType.warning)
            .show();
      }

      if (val2 > 12 && val2.toString().length == 2) {
        MessagesUtils.showAlert(
                context: context,
                title: 'El mes no puede ser superior a 12',
                alertType: AlertType.warning)
            .show();
      }

      if (val3 > 0 &&
          val3.toString().length == 4 &&
          (val3 < 1900 || val3 >= DateTime.now().year)) {
        MessagesUtils.showAlert(
                context: context,
                title: 'Ingrese un año válido',
                alertType: AlertType.warning)
            .show();
      }
    }
    _oldTextBirthDay = text;
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

  bool _validations() {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(_textEmail.text.trim());
    if (!emailValid) {
      MessagesUtils.showAlert(
              context: context,
              title: 'Por favor digite un correo valido',
              alertType: AlertType.warning)
          .show();
      return false;
    }

    return true;
  }

  void _registerUser() async {
    if (_formKey.currentState.validate()) {
      if (_validations()) {
        if (_textEmail.text.isNotEmpty && _textPassword.text.isNotEmpty) {
          try {
            await _userBloc
                .registerEmailUser(
                    _textEmail.text.trim(), _textPassword.text.trim())
                .then((registerUid) {
                      Navigator.pop(context);
                      MessagesUtils.showAlert(
                          context: context,
                          title: 'Usuario Registrado',
                          alertType: AlertType.success)
                          .show();

                    });

            _formKey.currentState.save();
          } on PlatformException catch (e) {
            if (e.message ==
                'The email address is already in use by another account.') {
              MessagesUtils.showAlert(
                context: context,
                title: 'El usuario ya se encuentra registrado',
                alertType: AlertType.warning,
              ).show();
            } else if (e.message ==
                'The given password is invalid. [ Password should be at least 6 characters ]') {
              MessagesUtils.showAlert(
                context: context,
                title: 'La contraseña debe tener al menos 6 caracteres.',
                alertType: AlertType.warning,
              ).show();
            }
          }
        }
      }
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }
}
