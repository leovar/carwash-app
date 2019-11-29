import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InvoicePrintPage extends StatelessWidget{
  final Invoice invoice;

  InvoicePrintPage({Key key, this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _containerBody(),
      ),
    );
  }

  Widget _containerBody(){
    return Column(
      children: <Widget>[

      ],
    );
  }
}