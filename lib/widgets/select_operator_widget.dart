import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/payment_methods/bloc/bloc_payment_method.dart';
import 'package:car_wash_app/payment_methods/model/payment_methods.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:flutter/material.dart';

class SelectOperatorWidget extends StatefulWidget {
  final PaymentMethod paymentMethodSelected;
  final Function(PaymentMethod) selectPaymentMethod;
  final Invoice currentInvoice;

  SelectOperatorWidget({
    Key? key,
    required this.paymentMethodSelected,
    required this.selectPaymentMethod,
    required this.currentInvoice,
  });

  @override
  State<StatefulWidget> createState() => _SelectOperatorWidget();
}

class _SelectOperatorWidget extends State<SelectOperatorWidget> {
  BlocInvoice _blocInvoice = BlocInvoice();
  BlocPaymentMethod _paymentMethodBloc = BlocPaymentMethod();
  late List<DropdownMenuItem<PaymentMethod>> _listPaymentMethods;
  late PaymentMethod _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    if (widget.paymentMethodSelected.name != '') {
      _selectedPaymentMethod = widget.paymentMethodSelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _getPaymentMethodsList(),
      ],
    );
  }

  Widget _getPaymentMethodsList() {
    return StreamBuilder(
      stream: _paymentMethodBloc.paymentMethodsStream(widget.currentInvoice.companyId),
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
    List<PaymentMethod> paymentsList = _paymentMethodBloc.buildPaymentMethods(snapshot.data.docs);
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
            color: Theme.of(context).textSelectionTheme.cursorColor,
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<PaymentMethod>> builtDropdownPaymentMethod(List payments) {
    List<DropdownMenuItem<PaymentMethod>> listItems = [];
    for (PaymentMethod documentPm in payments) {
      listItems.add(
        DropdownMenuItem(
          value: documentPm,
          child: Text(
            documentPm.name ?? '',
          ),
        ),
      );
    }
    if (_selectedPaymentMethod.id == '') {
      listItems.add(
        DropdownMenuItem(
          value: _selectedPaymentMethod,
          child: Text(
            _selectedPaymentMethod.name ?? '',
          ),
        ),
      );
    }
    return listItems;
  }

  onChangeDropDawPayment(PaymentMethod? payment) {
    setState(() {
      widget.selectPaymentMethod(payment ?? new PaymentMethod(companyId:  widget.currentInvoice.companyId));
      _selectedPaymentMethod = payment ?? new PaymentMethod(companyId: widget.currentInvoice.companyId);
    });
  }
}
