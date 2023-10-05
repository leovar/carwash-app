import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/ui/screens/invoice_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ItemWashingList extends StatefulWidget {
  final List<Invoice> listInvoices;
  final int index;
  final Function(Invoice) endWash;

  ItemWashingList({Key key, this.listInvoices, this.index, this.endWash});

  @override
  State<StatefulWidget> createState() => _ItemWashingList();
}

class _ItemWashingList extends State<ItemWashingList> {
  double _imageWith;
  String _iconVehicle;
  var _remainingPercentDuration = 0;
  var _invoiceDuration = 0;
  var formatter = new DateFormat('dd-MM-yyyy hh:mm a');
  var formatterHour = new DateFormat('hh:mm a');

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
    Invoice _invoiceList = widget.listInvoices[widget.index];
    DateTime dateStart = _invoiceList.dateStartWashing.toDate();
    DateTime dateCurrent = DateTime.now();
    Duration diff = dateCurrent.difference(dateStart);
    int washCurrentDuration = diff.inMinutes;
    _invoiceDuration = _invoiceList.washingServicesTime == null
        ? 0
        : _invoiceList.washingServicesTime;
    if (_invoiceList.countWashingWorkers > 1) {
      _invoiceDuration = (_invoiceDuration / _invoiceList.countWashingWorkers).round();
    }
    int remainingDuration = _invoiceDuration - washCurrentDuration;
    var calculateRemainingPercent = _invoiceDuration == 0
        ? 0
        : ((remainingDuration * 100) / _invoiceDuration).round();
    _remainingPercentDuration = calculateRemainingPercent < 0 ? 0 : calculateRemainingPercent;
    var servicesDurationTime = Duration(minutes: _invoiceDuration);
    var washCurrentDurationTime = Duration(minutes: washCurrentDuration);
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 115,
      ),
      child: Container(
        padding: EdgeInsets.only(
          right: 15,
        ),
        decoration: BoxDecoration(
          color: (widget.index % 2 == 0)
              ? Colors.white
              : Theme.of(context).dividerColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              flex: 6,
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
                                    _invoiceList.placa ?? '',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontFamily: "Lato",
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    _invoiceList.consecutive.toString(),
                                    style: TextStyle(
                                      color: Theme.of(context).accentColor,
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
                              'Celda: ' + _invoiceList.washingCell,
                              style: TextStyle(
                                color: Theme.of(context).cardColor,
                                fontFamily: "Lato",
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              'Inicio: ' +
                                  formatterHour.format(
                                      _invoiceList.dateStartWashing.toDate()),
                              style: TextStyle(
                                color: Theme.of(context).cardColor,
                                fontFamily: "Lato",
                                fontWeight: FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              'Tiempo en lavado: ' +
                                  _printDuration(washCurrentDurationTime),
                              style: TextStyle(
                                color: Theme.of(context).cardColor,
                                fontFamily: "Lato",
                                fontWeight: FontWeight.normal,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          SizedBox(height: 7),
                          Flexible(
                            child: LinearPercentIndicator(
                              width: MediaQuery.of(context).size.width - 180,
                              lineHeight: 16.0,
                              percent: (100 - _remainingPercentDuration) / 100,
                              center: Text(
                                "${(100 - _remainingPercentDuration)}%",
                                style: new TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              linearStrokeCap: LinearStrokeCap.roundAll,
                              backgroundColor: Theme.of(context).cursorColor,
                              progressColor: Colors.blue,
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
                margin: EdgeInsets.only(right: 2),
                child: ButtonTheme(
                  minWidth: 90,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(18.0),
                        side: BorderSide(color: Theme.of(context).accentColor)),
                    color: Theme.of(context).accentColor,
                    onPressed: () {
                      widget.endWash(_invoiceList);
                    },
                    textColor: Colors.white,
                    child: Text(
                      'Terminar'.toUpperCase(),
                      style: TextStyle(fontSize: 11),
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
