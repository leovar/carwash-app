import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:car_wash_app/invoice/model/payment_methods.dart';

class SelectOperatorWidget extends StatefulWidget {
  final Function(User) selectOperator;
  final User operatorSelected;
  final String idLocation;
  final String paymentMethodSelected;
  final Function(String) selectPaymentMethod;

  SelectOperatorWidget({
    Key key,
    this.operatorSelected,
    this.selectOperator,
    this.idLocation,
    this.paymentMethodSelected,
    this.selectPaymentMethod,
  });

  @override
  State<StatefulWidget> createState() => _SelectOperatorWidget();
}

class _SelectOperatorWidget extends State<SelectOperatorWidget> {
  BlocInvoice _blocInvoice = BlocInvoice();
  List<DropdownMenuItem<User>> _dropdownMenuItems;
  List<DropdownMenuItem<String>> _listPaymentMethods = List();
  String _selectedPaymentMethod;
  User _selectedUser;

  @override
  void initState() {
    super.initState();
    if (widget.operatorSelected.name != null &&
        widget.operatorSelected.name != '') {
      _selectedUser = widget.operatorSelected;
    }
    _listPaymentMethods.add(
      DropdownMenuItem(
        value: paymentMethodClass.datafono,
        child: Text(
          paymentMethodClass.datafono,
        ),
      ),
    );
    _listPaymentMethods.add(
      DropdownMenuItem(
        value: paymentMethodClass.transferencia,
        child: Text(
          paymentMethodClass.transferencia,
        ),
      ),
    );
    _listPaymentMethods.add(
      DropdownMenuItem(
        value: paymentMethodClass.efectivo,
        child: Text(
          paymentMethodClass.efectivo,
        ),
      ),
    );
    if (widget.paymentMethodSelected.isNotEmpty) {
      _selectedPaymentMethod = widget.paymentMethodSelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _getOperatorsList(),
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
        SizedBox(height: 12),
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

  onChangeDropDawnOperator(User selectedUser) {
    setState(() {
      widget.selectOperator(selectedUser);
      _selectedUser = selectedUser;
    });
  }

  onChangeDropDawPayment(String payment) {
    setState(() {
      widget.selectPaymentMethod(payment);
      _selectedPaymentMethod = payment;
    });
  }
}
