import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:flutter/material.dart';

class TotalFilterInvoicesWidget extends StatefulWidget {
  final List<Invoice> listInvoices;
  final VoidCallback openFilters;

  TotalFilterInvoicesWidget({Key? key, required this.listInvoices, required this.openFilters});

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          Container(
            height: 45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  'Filtrar por',
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 8),
                  child: InkWell(
                    onTap: widget.openFilters,
                    child: Image.asset(
                      'assets/images/icon_filter1.png',
                      width: 23.0,
                      height: 23.0,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
