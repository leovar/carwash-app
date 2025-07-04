import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/ui/screens/invoice_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemInvoicesList extends StatefulWidget {
  final List<Invoice> listInvoices;
  final int index;
  final bool updateDate;
  final bool isAdmon;
  final Function(Invoice) finishInvoice;
  final Function(Invoice) closeInvoice;

  ItemInvoicesList(
      {Key? key,
      required this.listInvoices,
      required this.index,
      required this.updateDate,
      required this.isAdmon,
      required this.finishInvoice,
      required this.closeInvoice});

  @override
  State<StatefulWidget> createState() => _ItemInvoicesList();
}

class _ItemInvoicesList extends State<ItemInvoicesList> {
  late double _imageWith;
  late String _iconVehicle;
  var formatter = new DateFormat('dd-MM-yyyy hh:mm a');

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
      case 4:
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
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InvoicePage(
                      showDrawer: false,
                      invoiceToEdit: widget.listInvoices[widget.index],
                    )));
      },
      child: _itemDecoration(widget.listInvoices[widget.index]),
    );
  }

  Widget _itemDecoration(Invoice invoiceList) {
    bool _visibleClosesText = ((invoiceList.invoiceClosed ?? false) &&
            (invoiceList.paymentMethod ?? '') != '') ??
        false;
    bool _cancelInvoice = invoiceList.cancelledInvoice ?? false;
    bool _finishedInvoice =
    ((invoiceList.countOperators ?? 0) > 0) ? true : false;
    final formatterNumber = NumberFormat("#,###");
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 83,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: (widget.index % 2 == 0) ? Colors.white : Color(0xFFF1F1F1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 4,
              child: Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 8, right: 18),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Image.asset(_iconVehicle, width: _imageWith),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    invoiceList.consecutive.toString(),
                                    style: TextStyle(
                                      color: Color(0xFF59B258),
                                      fontFamily: "Lato",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17.0,
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: widget.isAdmon,
                                  child: Expanded(
                                    child: Text(
                                      '\$${formatterNumber.format(invoiceList.totalPrice)}',
                                      style: TextStyle(
                                        color: Color(0xFF59B258),
                                        fontFamily: "Lato",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 5),
                          Flexible(
                            child: Text(
                              invoiceList.placa ?? '',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontFamily: "Lato",
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Visibility(
                              visible: (invoiceList.operatorsSplit != null)
                                  ? true
                                  : false,
                              child: Text(
                                invoiceList.operatorsSplit ?? '',
                                style: TextStyle(
                                  color: Color(0xFF787A71),
                                  fontFamily: "Lato",
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              formatter
                                  .format(invoiceList.creationDate!.toDate()),
                              style: TextStyle(
                                color: Color(0xFF787A71),
                                fontFamily: "Lato",
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //Text(invoiceList.totalPrice.toString()),
            Flexible(
              flex: 2,
              child: Container(
                alignment: Alignment.centerRight,
                child: _cancelInvoice
                    ? Container(
                        margin: EdgeInsets.only(
                          right: 15,
                        ),
                        child: Text(
                          'ANULADA',
                          style: TextStyle(
                            color: Colors.red,
                            fontFamily: "Lato",
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                      )
                    : _visibleClosesText
                        ? Container(
                            margin: EdgeInsets.only(
                              right: 15,
                            ),
                            child: Text(
                              'CERRADA',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontFamily: "Lato",
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                          )
                        : _finishedInvoice
                            ? Container(
                                margin: EdgeInsets.only(right: 2),
                                child: ButtonTheme(
                                  minWidth: 84,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          new BorderRadius.circular(18.0),
                                          side: BorderSide(
                                              color:
                                              Theme.of(context).colorScheme.secondary)),
                                      backgroundColor: Theme.of(context).colorScheme.secondary,
                                      foregroundColor: Colors.white,
                                      textStyle: TextStyle(fontSize: 12),
                                    ),
                                    onPressed: () {
                                      widget.closeInvoice(invoiceList);
                                    },
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Completar'.toUpperCase(),
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                margin: EdgeInsets.only(right: 2),
                                child: ButtonTheme(
                                  minWidth: 84,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          new BorderRadius.circular(18.0),
                                          side: BorderSide(
                                              color:
                                              Theme.of(context).colorScheme.error)),
                                      backgroundColor: Theme.of(context).colorScheme.error,
                                      foregroundColor: Colors.white,
                                      textStyle: TextStyle(fontSize: 12),
                                    ),
                                    onPressed: () {
                                      widget.finishInvoice(invoiceList);
                                    },
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Terminar'.toUpperCase(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
