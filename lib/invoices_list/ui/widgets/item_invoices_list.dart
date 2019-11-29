import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/ui/screens/invoice_page.dart';
import 'package:car_wash_app/invoices_list/model/invoice_list_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemInvoicesList extends StatefulWidget {
  final List<Invoice> listInvoices;
  final List<InvoiceListModel> listInvoicesModel;
  final int index;
  final bool updateDate;

  ItemInvoicesList(
      {Key key,
      this.listInvoices,
      this.listInvoicesModel,
      this.index,
      this.updateDate});

  @override
  State<StatefulWidget> createState() => _ItemInvoicesList();
}

class _ItemInvoicesList extends State<ItemInvoicesList> {
  double _imageWith;
  String _iconVehicle;

  @override
  void initState() {
    super.initState();
    switch (widget.listInvoices[widget.index].uidVehicleType) {
      case 1:
        _imageWith = 38;
        _iconVehicle = "assets/images/icon_car_admin.png";
        break;
      case 2:
        _imageWith = 37;
        _iconVehicle = 'assets/images/icon_suv_car_admin.png';
        break;
      case 3:
        _imageWith = 34;
        _iconVehicle = 'assets/images/icon_motorcycle_admin.png';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.updateDate) {
      //this._getInfoVehicles();
    }
    return InkWell(
      splashColor: Colors.white,
      onTap: () {
        Navigator.push(context,
          MaterialPageRoute(builder: (context) => InvoicePage(
            showDrawer: false,
            invoiceToEdit: widget.listInvoices[widget.index],
          ))
        );
      },
      child: _itemDecoration(widget.listInvoices[widget.index]),
    );
  }

  Widget _itemDecoration(Invoice invoiceList) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: (widget.index % 2 == 0) ? Colors.white : Color(0xFFF1F1F1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 8, right: 22),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Image.asset(_iconVehicle, width: _imageWith),
                ),
              ),
              Wrap(
                direction: Axis.vertical,
                children: <Widget>[
                  Text(
                    invoiceList.placa ?? '',
                    style: TextStyle(
                      color: Color(0xFF787A71),
                      fontFamily: "Lato",
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                  Visibility(
                    visible:
                        (invoiceList.userOperatorName != null) ? true : false,
                    child: Text(
                      invoiceList.userOperatorName ?? '',
                      style: TextStyle(
                        color: Color(0xFF787A71),
                        fontFamily: "Lato",
                        fontWeight: FontWeight.normal,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          //Text(invoiceList.totalPrice.toString()),
          Container(
            margin: EdgeInsets.only(right: 8),
            alignment: Alignment.centerRight,
            child: Text(
              invoiceList.consecutive.toString(),
              style: TextStyle(
                color: Color(0xFF59B258),
                fontFamily: "Lato",
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
