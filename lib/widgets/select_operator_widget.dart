import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/payment_methods.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SelectOperatorWidget extends StatefulWidget {
  final Function(User) selectOperator;
  final User operatorSelected;
  final String idLocation;
  final PaymentMethod paymentMethodSelected;
  final Function(PaymentMethod) selectPaymentMethod;
  final Invoice currentInvoice;
  final Function(Invoice) finishInvoice;

  SelectOperatorWidget({
    Key key,
    this.operatorSelected,
    this.selectOperator,
    this.idLocation,
    this.paymentMethodSelected,
    this.selectPaymentMethod,
    this.currentInvoice,
    this.finishInvoice,
  });

  @override
  State<StatefulWidget> createState() => _SelectOperatorWidget();
}

class _SelectOperatorWidget extends State<SelectOperatorWidget> {
  BlocInvoice _blocInvoice = BlocInvoice();
  List<DropdownMenuItem<User>> _dropdownMenuItems;
  List<DropdownMenuItem<PaymentMethod>> _listPaymentMethods;
  PaymentMethod _selectedPaymentMethod;
  User _selectedUser;

  @override
  void initState() {
    super.initState();
    if (widget.operatorSelected.name != null &&
        widget.operatorSelected.name != '') {
      _selectedUser = widget.operatorSelected;
    }
    if (widget.paymentMethodSelected.name != null &&
        widget.paymentMethodSelected.name != '') {
      _selectedPaymentMethod = widget.paymentMethodSelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _getOperatorsList(),
        SizedBox(height: 12),
        _buttonFinishInvoice(),
        SizedBox(height: 12),
        _getPaymentMethodsList(),
      ],
    );
  }

  Widget _getOperatorsList() {
    return StreamBuilder(
      stream: _blocInvoice.operatorsByLocationStream(widget.idLocation),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return _chargeDropOperators(snapshot);
        }
      },
    );
  }

  Widget _chargeDropOperators(AsyncSnapshot snapshot) {
    List<User> operatorsList =
        _blocInvoice.buildOperators(snapshot.data.documents);
    _dropdownMenuItems = builtDropdownMenuItems(operatorsList);

    return Column(
      children: [
        DropdownButton(
          isExpanded: true,
          items: _dropdownMenuItems,
          value: _selectedUser,
          onChanged: onChangeDropDawnOperator,
          hint: Text(
            "Seleccione el operador...",
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Theme.of(context).cardColor,
          ),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(
            fontFamily: "AvenirNext",
            fontWeight: FontWeight.normal,
            color: Theme.of(context).cardColor,
          ),
          underline: Container(
            height: 1,
            color: Theme.of(context).cursorColor,
          ),
        ),
      ],
    );
  }

  Widget _buttonFinishInvoice() {
    return Container(
      alignment: Alignment.center,
      child: ButtonTheme(
        minWidth: 84,
        child: RaisedButton(
          shape: RoundedRectangleBorder(
              borderRadius:
              new BorderRadius.circular(6.0),
              side: BorderSide(
                  color: Theme.of(context).accentColor)),
          color: Theme.of(context).accentColor,
          onPressed: widget.currentInvoice.invoiceClosed??false ? null : () {
            setState(() {
              widget.finishInvoice(widget.currentInvoice);
              Navigator.pop(context);
            });
          },
          textColor: Colors.white,
          child: Text(
            'Terminar'.toUpperCase(),
            style: TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _getPaymentMethodsList() {
    return StreamBuilder(
      stream: _blocInvoice.paymentMethodsStream(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return _chargeDropPaymentMethods(snapshot);
        }
      },
    );
  }

  Widget _chargeDropPaymentMethods(AsyncSnapshot snapshot) {
    List<PaymentMethod> paymentsList = _blocInvoice.buildPaymentMethods(snapshot.data.documents);
    _listPaymentMethods = builtDropdownPaymentMethod(paymentsList);
    return Column(
      children: [
        DropdownButton(
          isExpanded: true,
          items: _listPaymentMethods,
          value: _selectedPaymentMethod,
          onChanged: onChangeDropDawPayment,
          hint: Text(
            "Seleccione el método de pago...",
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Theme.of(context).cardColor,
          ),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(
            fontFamily: "AvenirNext",
            fontWeight: FontWeight.normal,
            color: Theme.of(context).cardColor,
          ),
          underline: Container(
            height: 1,
            color: Theme.of(context).cursorColor,
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<User>> builtDropdownMenuItems(List operators) {
    List<DropdownMenuItem<User>> listItems = List();
    for (User documentOpe in operators) {
      listItems.add(
        DropdownMenuItem(
          value: documentOpe,
          child: Text(
            documentOpe.name,
          ),
        ),
      );
    }
    return listItems;
  }

  List<DropdownMenuItem<PaymentMethod>> builtDropdownPaymentMethod(List payments) {
    List<DropdownMenuItem<PaymentMethod>> listItems = List();
    for (PaymentMethod documentPm in payments) {
      listItems.add(
        DropdownMenuItem(
          value: documentPm,
          child: Text(
            documentPm.name,
          ),
        ),
      );
    }
    return listItems;
  }

  onFinishInvoicePressed() {
    widget.finishInvoice(widget.currentInvoice);
  }

  onChangeDropDawnOperator(User selectedUser) {
    setState(() {
      widget.selectOperator(selectedUser);
      _selectedUser = selectedUser;
    });
  }

  onChangeDropDawPayment(PaymentMethod payment) {
    setState(() {
      widget.selectPaymentMethod(payment);
      _selectedPaymentMethod = payment;
    });
  }
}
