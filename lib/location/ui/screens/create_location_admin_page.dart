import 'package:car_wash_app/invoice/ui/widgets/text_field_input.dart';
import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class CreateLocationAdminPage extends StatefulWidget {
  final Location currentLocation;

  CreateLocationAdminPage({Key key, this.currentLocation});

  @override
  State<StatefulWidget> createState() => _CreateLocationAdminPage();
}

class _CreateLocationAdminPage extends State<CreateLocationAdminPage> {
  BlocLocation _blocLocation;

  GlobalKey btnChangeImageProfile = GlobalKey();
  bool _validateName = false;
  bool _validateAddress = false;
  bool _validateDianResolution = false;
  bool _validateFinalConsec = false;
  bool _validateInitConsec = false;
  bool _validateNit = false;
  bool _validatePrefix = false;
  bool _validatePhone = false;
  bool _validateRegimen = false;
  final _textLocationName = TextEditingController();
  final _textAddress = TextEditingController();
  final _textRegimen = TextEditingController();
  final _textPhone = TextEditingController();
  final _textDianResolution = TextEditingController();
  final _textFinalConsec = TextEditingController();
  final _textInitConsec = TextEditingController();
  final _textNit = TextEditingController();
  final _textPrefix = TextEditingController();
  final _textTotalCells = TextEditingController();
  final double _heightTextField = 60;
  bool _locationActive = true;
  bool _sendSms = true;
  bool _sendWp = false;
  bool _printIva = true;
  Location _locationSelected;

  @override
  void initState() {
    super.initState();
    if (widget.currentLocation != null) {
      _locationSelected = widget.currentLocation;
      _selectLocationList();
    }
  }

  @override
  Widget build(BuildContext context) {
    _blocLocation = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Sede",
          style: TextStyle(
            fontFamily: "Lato",
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          child: _containerBody(),
        ),
      ),
    );
  }

  Widget _containerBody() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 17, horizontal: 16),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 12),
            Flexible(
              child: Container(
                child: TextFieldInput(
                  labelText: 'Nombre de Sede',
                  textController: _textLocationName,
                  validate: _validateName,
                  textValidate: 'Escriba el nombre de la sede',
                ),
              ),
            ),
            SizedBox(height: 9),
            Container(
              height: _heightTextField,
              child: TextFieldInput(
                labelText: 'Direccion',
                textController: _textAddress,
                validate: _validateAddress,
                textValidate: 'Escriba un dirección',
                inputType: TextInputType.multiline,
                maxLines: null,
              ),
            ),
            SizedBox(height: 9),
            Container(
              height: _heightTextField,
              child: TextFieldInput(
                labelText: 'Teléfono',
                textController: _textPhone,
                validate: _validatePhone,
                textValidate: 'Escriba un valor',
                inputType: TextInputType.number,
                textInputFormatter: [
                  WhitelistingTextInputFormatter(RegExp("^[0-9.]*")),
                  LengthLimitingTextInputFormatter(11),
                ],
              ),
            ),
            SizedBox(height: 9),
            Container(
              height: _heightTextField,
              child: TextFieldInput(
                labelText: 'Nit',
                textController: _textNit,
                validate: _validateNit,
                textValidate: 'Escriba un nit',
              ),
            ),
            SizedBox(height: 9),
            Container(
              height: _heightTextField,
              child: TextFieldInput(
                labelText: 'Régimen',
                textController: _textRegimen,
                validate: _validateRegimen,
                textValidate: 'Escriba un valor',
              ),
            ),
            SizedBox(height: 9),
            Container(
              height: _heightTextField,
              child: TextFieldInput(
                labelText: 'Resolucion de Dian',
                textController: _textDianResolution,
                validate: _validateDianResolution,
                textValidate: 'Escriba un valor',
              ),
            ),
            SizedBox(height: 9),
            Container(
              height: _heightTextField,
              child: TextFieldInput(
                labelText: 'Consecutivo Inicial',
                textController: _textInitConsec,
                validate: _validateInitConsec,
                textValidate: 'Escriba un valor',
                inputType: TextInputType.number,
                textInputFormatter: [
                  WhitelistingTextInputFormatter(RegExp("^[0-9.]*"))
                ],
              ),
            ),
            SizedBox(height: 9),
            Container(
              height: _heightTextField,
              child: TextFieldInput(
                labelText: 'Consecutivo Final',
                textController: _textFinalConsec,
                validate: _validateFinalConsec,
                textValidate: 'Escriba un valor',
                inputType: TextInputType.number,
                textInputFormatter: [
                  WhitelistingTextInputFormatter(RegExp("^[0-9.]*"))
                ],
              ),
            ),
            SizedBox(height: 9),
            Container(
              height: _heightTextField,
              child: TextFieldInput(
                labelText: 'Prefijo de Numeración',
                textController: _textPrefix,
                validate: _validatePrefix,
                textValidate: 'Escriba un valor',
              ),
            ),
            SizedBox(height: 9),
            Container(
              height: _heightTextField,
              child: TextFieldInput(
                labelText: 'Celdas Disponibles',
                textController: _textTotalCells,
                validate: _validatePrefix,
                textValidate: 'Escriba un valor',
                inputType: TextInputType.number,
                textInputFormatter: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                ],
              ),
            ),
            SizedBox(height: 9),
            Flexible(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _locationActive,
                    onChanged: (bool value) {
                      setState(() {
                        _locationActive = value;
                      });
                    },
                    checkColor: Colors.white,
                    activeColor: Color(0xFF59B258),
                  ),
                  Text(
                    "Sede Activa",
                    style: TextStyle(
                      fontFamily: "Lato",
                      decoration: TextDecoration.none,
                      color: Color(0xFFAEAEAE),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 9),
            Flexible(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _sendSms,
                    onChanged: (bool value) {
                      _onChangeSendNotification(1, value);
                    },
                    checkColor: Colors.white,
                    activeColor: Color(0xFF59B258),
                  ),
                  Text(
                    "Enviar Notificación por SMS",
                    style: TextStyle(
                      fontFamily: "Lato",
                      decoration: TextDecoration.none,
                      color: Color(0xFFAEAEAE),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 9),
            Flexible(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _sendWp,
                    onChanged: (bool value) {
                      _onChangeSendNotification(2, value);
                    },
                    checkColor: Colors.white,
                    activeColor: Color(0xFF59B258),
                  ),
                  Text(
                    "Enviar Notificación por WhatsApp",
                    style: TextStyle(
                      fontFamily: "Lato",
                      decoration: TextDecoration.none,
                      color: Color(0xFFAEAEAE),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 9),
            Flexible(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _printIva,
                    onChanged: (bool value) {
                      setState(() {
                        _printIva = value;
                      });
                    },
                    checkColor: Colors.white,
                    activeColor: Color(0xFF59B258),
                  ),
                  Text(
                    "Imprimir Iva",
                    style: TextStyle(
                      fontFamily: "Lato",
                      decoration: TextDecoration.none,
                      color: Color(0xFFAEAEAE),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 9),
            Flexible(
              child: _buttonSave(),
            ),
            SizedBox(height: 9),
          ],
        ),
      ),
    );
  }

  Widget _buttonSave() {
    return Container(
      height: 100,
      child: Align(
        alignment: Alignment.center,
        child: RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
          color: Color(0xFF59B258),
          child: Text(
            "Guardar",
            style: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 19,
            ),
          ),
          onPressed: () {
            _saveUser();
          },
        ),
      ),
    );
  }

  /// Functions

  void _selectLocationList() {
    _validateName = false;
    _validateAddress = false;
    _validateDianResolution = false;
    _validateNit = false;
    _validateInitConsec = false;
    _validateFinalConsec = false;
    _validatePrefix = false;
    _validatePhone = false;
    _validateRegimen = false;
    _textLocationName.text = _locationSelected.locationName;
    _textAddress.text = _locationSelected.address;
    _textDianResolution.text = _locationSelected.dianResolution;
    _textNit.text = _locationSelected.nit;
    _textInitConsec.text = _locationSelected.initConcec.toString();
    _textFinalConsec.text = _locationSelected.finalConsec.toString();
    _textPrefix.text = _locationSelected.prefix;
    _locationActive = _locationSelected.active;
    _sendSms = _locationSelected.sendMessageSms?? false;
    _sendWp = _locationSelected.sendMessageWp?? false;
    _printIva = _locationSelected.printIva;
    _textRegimen.text = _locationSelected.regimen;
    _textPhone.text = _locationSelected.phoneNumber;
    _textTotalCells.text = _locationSelected.totalCells == null ? '0' : _locationSelected.totalCells.toString();
  }

  bool _validateInputs() {
    bool canSave = true;
    if (_textLocationName.text.isEmpty) {
      _validateName = true;
      canSave = false;
    } else
      _validateName = false;

    if (_textAddress.text.isEmpty) {
      _validateAddress = true;
      canSave = false;
    } else
      _validateAddress = false;

    if (_textNit.text.isEmpty) {
      _validateNit = true;
      canSave = false;
    } else
      _validateNit = false;

    if (_textInitConsec.text.isEmpty) {
      _validateInitConsec = true;
      canSave = false;
    } else
      _validateInitConsec = false;

    if (_textFinalConsec.text.isEmpty) {
      _validateFinalConsec = true;
      canSave = false;
    } else
      _validateFinalConsec = false;

    if (_textPrefix.text.isEmpty) {
      _validatePrefix = true;
      canSave = false;
    } else
      _validatePrefix = false;

    if (canSave == false) {
      setState(() {
        MessagesUtils.showAlert(context: context, title: 'Faltan campos por llenar').show();
      });
    }

    return canSave;
  }

  //1. send Sms, 2. send WhatsApp
  void _onChangeSendNotification(int notificationType, bool value) {
    setState(() {
      switch (notificationType) {
        case 1:
          _sendSms = value;
          _sendWp = false;
          break;
        case 2:
          _sendSms = false;
          _sendWp = value;
          break;
      }
    });
  }

  void _saveUser() async {
    if (_validateInputs()) {
      MessagesUtils.showAlertWithLoading(context: context, title: 'Guardando')
          .show();

      var minActiveCells = 0;
      if (_locationSelected != null) {
        var totalCells = int.tryParse(_textTotalCells.text.trim()) ?? 0;
        if ((_locationSelected?.activeCells ?? 0) > totalCells)
          minActiveCells = 0;
        else
          minActiveCells = _locationSelected?.activeCells ?? 0;
      }

      var location = Location(
        id: _locationSelected != null ? _locationSelected.id : null,
        locationName: _textLocationName.text.trim(),
        address: _textAddress.text.trim(),
        nit: _textNit.text.trim(),
        dianResolution: _textDianResolution.text.trim(),
        initConcec: int.tryParse(_textInitConsec.text.trim()) ?? 0.0,
        finalConsec: int.tryParse(_textFinalConsec.text.trim()) ?? 0.0,
        prefix: _textPrefix.text.trim(),
        active: _locationActive,
        creationDate: _locationSelected != null ? _locationSelected.creationDate : Timestamp.now(),
        sendMessageSms: _sendSms,
        sendMessageWp: _sendWp,
        printIva: _printIva,
        phoneNumber: _textPhone.text.trim(),
        regimen: _textRegimen.text.trim(),
        activeCells: _locationSelected != null ? minActiveCells : 0,
        totalCells: int.tryParse(_textTotalCells.text.trim()) ?? 0,
      );

      _blocLocation.updateLocationData(location);

      Navigator.pop(context);
      Navigator.pop(context);

      //_clearData();
    }
  }
}