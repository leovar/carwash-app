import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/ui/screens/invoice_page.dart';
import 'package:car_wash_app/main.dart';
import 'package:car_wash_app/reports/model/card_report.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemProductivityReportList extends StatefulWidget {
  final CardReport cardReport;
  final Function(String, List<Invoice>) servicesDetail;

  ItemProductivityReportList(
      {Key key,
      this.cardReport,
      this.servicesDetail});

  @override
  State<StatefulWidget> createState() => _ItemProductivityReportList();
}

class _ItemProductivityReportList extends State<ItemProductivityReportList> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 86,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          color: Colors.white,
          elevation: 5,
          child: InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              widget.servicesDetail(widget.cardReport.operatorName, widget.cardReport.invoicesList);
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Flexible(
                  flex: 4,
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.only(left: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Flexible(
                                child: Text(
                                  widget.cardReport.operatorName,
                                  style: TextStyle(
                                    color: Theme.of(context).cardColor,
                                    fontFamily: "Lato",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17.0,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              Flexible(
                                child: Text(
                                  'Total:',
                                  style: TextStyle(
                                    color: Theme.of(context).accentColor,
                                    fontFamily: "Lato",
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(
                            right: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.account_circle,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                              SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  widget.cardReport.countServices.toString() + ' Servicios',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontFamily: "Lato",
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 3),
                      Flexible(
                        child: Container(
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(
                            right: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.supervisor_account,
                                color: Theme.of(context).primaryColor,
                                size: 20,
                              ),
                              SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  widget.cardReport.countSharedServices.toString() + ' Servicios',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontFamily: "Lato",
                                    fontWeight: FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.only(
                            right: 12,
                          ),
                          child: Text(
                              '\$${formatter.format(widget.cardReport.totalPrice)}',
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontFamily: "Lato",
                              fontWeight: FontWeight.normal,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
