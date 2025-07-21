import 'package:car_wash_app/invoice/model/invoice_history_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InfoLastServicesByVehicle extends StatelessWidget {
  final List<InvoiceHistoryList> listHistoryInvoices;
  final double _widthContainer = 300;
  final formatter = new DateFormat('dd-MM-yyyy');

  InfoLastServicesByVehicle({Key? key, required this.listHistoryInvoices});

  @override
  Widget build(BuildContext context) {
    List<InvoiceHistoryList> _listInvoices = listHistoryInvoices;
    _listInvoices.sort((a, b) => b.creationDate.compareTo(a.creationDate));
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
              'Ha realizado ${_listInvoices.length} servicios',
              style: Theme.of(context).textTheme.displaySmall),
          Container(
            height: 200,
            width: _widthContainer,
            child: ListView.builder(
              itemCount: _listInvoices.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return _itemServices(context, _listInvoices[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemServices(BuildContext context, InvoiceHistoryList invoice) {
    final formatterPrice = NumberFormat("#,###");
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 30),
      child: Container(
        width: _widthContainer,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFD8D8D8),
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 90,
              child: Text(

                formatter.format(invoice.creationDate.toDate()),
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      invoice.lastService,
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      'Factura: ${invoice.consecutive}',
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Flexible(
              child: Text(
                '\$${formatterPrice.format(invoice.price)}',
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
