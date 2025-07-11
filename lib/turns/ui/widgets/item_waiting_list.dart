import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemWaitingList extends StatefulWidget {
  final List<Invoice> listInvoices;
  final int index;
  final Function(Invoice) assignTurn;

  ItemWaitingList(
      {Key? key,
      required this.listInvoices,
      required this.index,
      required this.assignTurn});

  @override
  State<StatefulWidget> createState() => _ItemWaitingList();
}

class _ItemWaitingList extends State<ItemWaitingList> {
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
    Invoice invoiceList = widget.listInvoices[widget.index];
    int invoiceDuration = invoiceList.washingServicesTime == null ? 0 : invoiceList.washingServicesTime??0;
    var durationTime = Duration(minutes: invoiceDuration);
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 95,
      ),
      child: Container(
        padding: EdgeInsets.only(
          right: 15,
        ),
        decoration: BoxDecoration(
          color: (widget.index % 2 == 0) ? Colors.white : Theme.of(context).dividerColor,
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
                                      color: Theme.of(context).colorScheme.secondary,
                                      fontFamily: "Lato",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17.0,
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
                            child: Text(
                              'Tiempo de lavado: ' + _printDuration(durationTime),
                              style: TextStyle(
                                color: Theme.of(context).cardColor,
                                fontFamily: "Lato",
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              formatter
                                  .format(invoiceList.creationDate!.toDate()),
                              style: TextStyle(
                                color: Theme.of(context).cardColor,
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
              flex: 1,
              child: Container(
                margin: EdgeInsets.only(right: 2),
                child: ButtonTheme(
                  minWidth: 84,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          new BorderRadius.circular(18.0),
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.secondary)),
                    ),
                    onPressed: () {
                      widget.assignTurn(invoiceList);
                    },
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Lavar'.toUpperCase(),
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

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
