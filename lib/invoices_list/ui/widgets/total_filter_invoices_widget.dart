import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoices_list/model/invoice_list_model.dart';
import 'package:flutter/material.dart';

class TotalFilterInvoicesWidget extends StatefulWidget {
  List<Invoice> listInvoices;
  updateInvoicesList(List<Invoice> listInvoicesUpdate){
    listInvoices = listInvoicesUpdate;
  }

  TotalFilterInvoicesWidget({Key key, this.listInvoices});

  @override
  State<StatefulWidget> createState() => _TotalFilterInvoicesWidget();
}

class _TotalFilterInvoicesWidget extends State<TotalFilterInvoicesWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFD8D8D8),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            height: 45,
            margin: EdgeInsets.only(left: 7.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total facturas: ${widget.listInvoices.length}',
                style: TextStyle(
                  fontFamily: "Lato",
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Color(0xFF27AEBB),
                ),
              ),
            ),
          ),
          Container(
            height: 45,
            width: MediaQuery.of(context).size.width - 195.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Filtrar por',
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                    color: Color(0xFF27AEBB),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: Image.asset('assets/images/icon_filter1.png', width: 23.0, height: 23.0,),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}