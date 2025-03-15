import 'package:car_wash_app/payment_methods/bloc/bloc_payment_method.dart';
import 'package:car_wash_app/payment_methods/model/payment_methods.dart';
import 'package:car_wash_app/payment_methods/ui/widgets/item_payment_method.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

import 'create_payment_method_admin_page.dart';

class PaymentMethodAdminPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _PaymentMethodAdminPage();
}

class _PaymentMethodAdminPage extends State<PaymentMethodAdminPage> {
  BlocPaymentMethod _paymentMethodBloc;
  List<PaymentMethod> _paymentMethodsList = [];

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
          "Métodos de Pago",
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
        child: _bodyContainer(),
      ),
    );
  }

  Widget _bodyContainer() {
    return Container(
      padding: EdgeInsets.only(bottom: 17),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _listPaymentMethodsStream(),
          _buttonNewUser(),
        ],
      ),
    );
  }

  Widget _listPaymentMethodsStream() {
    return StreamBuilder(
      stream: _paymentMethodBloc.allPaymentMethodsStream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return _getDataPaymentMethodsList(snapshot);
        }
      },
    );
  }

  Widget _getDataPaymentMethodsList(AsyncSnapshot snapshot) {
    _paymentMethodsList = _paymentMethodBloc.buildPaymentMethods(snapshot.data.documents);
    _paymentMethodsList.sort((a, b) => a.name.compareTo(b.name));
    return Flexible(
      child: ListView.builder(
        itemCount: _paymentMethodsList.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return ItemPaymentMethodAdmin(_paymentMethodsList, index);
        },
      ),
    );
  }

  Widget _buttonNewUser() {
    return Container(
      height: 60,
      margin: EdgeInsets.only(top: 8,),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
          color: Color(0xFF59B258),
          child: Text(
            "Nuevo método de pago",
            style: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 19,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return BlocProvider(
                    bloc: BlocPaymentMethod(),
                    child: CreatePaymentMethodAdminPage(),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

}