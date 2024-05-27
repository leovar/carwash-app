import 'package:car_wash_app/invoice/ui/widgets/text_field_input.dart';
import 'package:car_wash_app/payment_methods/bloc/bloc_payment_method.dart';
import 'package:car_wash_app/payment_methods/model/payment_methods.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class CreatePaymentMethodAdminPage extends StatefulWidget {
  final PaymentMethod currentPaymentMethod;

  CreatePaymentMethodAdminPage({Key key, this.currentPaymentMethod});

  @override
  State<StatefulWidget> createState() => _CreatePaymentMethodAdminPage();
}

class _CreatePaymentMethodAdminPage
    extends State<CreatePaymentMethodAdminPage> {
  BlocPaymentMethod _paymentMethodBloc;
  bool _validateName = false;
  final _textName = TextEditingController();
  bool _registerActive = true;

  PaymentMethod _paymentMethodSelected;

  @override
  void initState() {
    super.initState();
    if (widget.currentPaymentMethod != null) {
      _paymentMethodSelected = widget.currentPaymentMethod;
      _selectLocationList();
    }
  }

  @override
  Widget build(BuildContext context) {
    _paymentMethodBloc = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Método de Pago",
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
          children: [
            SizedBox(height: 12),
            Flexible(
              child: Container(
                child: TextFieldInput(
                  labelText: 'Nombre de método de pago',
                  textController: _textName,
                  validate: _validateName,
                  textValidate: 'Escriba el nombre del método de pago',
                ),
              ),
            ),
            SizedBox(height: 9),
            Flexible(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _registerActive,
                    onChanged: (bool value) {
                      setState(() {
                        _registerActive = value;
                      });
                    },
                    checkColor: Colors.white,
                    activeColor: Color(0xFF59B258),
                  ),
                  Text(
                    "Método de pago activo",
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
            _savePaymentMethod();
          },
        ),
      ),
    );
  }

  /// Functions

  void _selectLocationList() {
    _validateName = false;
    _textName.text = _paymentMethodSelected.name;
    _registerActive = _paymentMethodSelected.active;
  }

  bool _validateInputs() {
    bool canSave = true;
    if (_textName.text.isEmpty) {
      _validateName = true;
      canSave = false;
    } else
      _validateName = false;

    if (canSave == false) {
      setState(() {
        MessagesUtils.showAlert(
                context: context, title: 'Faltan campos por llenar')
            .show();
      });
    }
    return canSave;
  }

  void _savePaymentMethod() async {
    if (_validateInputs()) {
      MessagesUtils.showAlertWithLoading(context: context, title: 'Guardando')
          .show();

      var paymentMethodData = PaymentMethod(
        id: _paymentMethodSelected != null ? _paymentMethodSelected.id : null,
        name: _textName.text.trim(),
        active: _registerActive,
      );

      _paymentMethodBloc.updatePaymentMethodData(paymentMethodData);

      Navigator.pop(context);
      Navigator.pop(context);
    }
  }
}
