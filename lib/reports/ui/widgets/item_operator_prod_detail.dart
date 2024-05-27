import 'dart:ffi';

import 'package:car_wash_app/invoice/model/configuration.dart';
import 'package:car_wash_app/reports/model/operator_prod_card.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ItemOperatorProductivityDetail extends StatelessWidget {
  final OperatorProductivityCard cardReport;
  final Configuration configuration;

  ItemOperatorProductivityDetail(
      {Key key, @required this.cardReport, this.configuration});

  @override
  Widget build(BuildContext context) {
    int _commissionDay = (((cardReport.totalCommissionDay ?? 0) * 100) /
            (configuration.salaryDay ?? 0))
        .round();
    int _commissionMonth = (((cardReport.totalCommissionMonth ?? 0) * 100) /
            (configuration.salaryMonth ?? 0))
        .round();

    Color _colorBarDay = Colors.blue;
    Color _colorBarMonth = Colors.blue;
    if (_commissionDay < 33) {
      _colorBarDay = Colors.red;
    } else if (_commissionDay > 33 && _commissionDay < 70) {
      _colorBarDay = Colors.amber;
    } else {
      _colorBarDay = Colors.lightGreen;
    }

    if (_commissionMonth < 33) {
      _colorBarMonth = Colors.red;
    } else if (_commissionMonth > 33 && _commissionMonth < 70) {
      _colorBarMonth = Colors.amber;
    } else {
      _colorBarMonth = Colors.lightGreen;
    }


    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 86,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          color: Colors.white,
          elevation: 5,
          child: Column(
            children: [
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        cardReport.operatorName,
                        style: TextStyle(
                          color: Theme.of(context).cardColor,
                          fontFamily: "Lato",
                          fontWeight: FontWeight.bold,
                          fontSize: 17.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'Acumulado del día: ' + '${cardReport.invoicesPerDay} Lavadas',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontFamily: "Lato",
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(left: 8),
                      child: LinearPercentIndicator(
                        width: MediaQuery.of(context).size.width - 50,
                        lineHeight: 16.0,
                        percent:
                            (_commissionDay > 100 ? 100 : _commissionDay) / 100,
                        center: Text(
                          "${_commissionDay}%",
                          style: new TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        linearStrokeCap: LinearStrokeCap.roundAll,
                        backgroundColor: Theme.of(context).cursorColor,
                        progressColor: _colorBarDay,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(left: 8),
                      child: Text(
                        'Acumulado del mes: ' + '${cardReport.invoicesList.length} Lavadas',
                        style: TextStyle(
                          color: Theme.of(context).accentColor,
                          fontFamily: "Lato",
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: EdgeInsets.only(left: 8),
                      child: LinearPercentIndicator(
                        width: MediaQuery.of(context).size.width - 50,
                        lineHeight: 16.0,
                        percent:
                            (_commissionMonth > 100 ? 100 : _commissionMonth) /
                                100,
                        center: Text(
                          "${_commissionMonth}%",
                          style: new TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        linearStrokeCap: LinearStrokeCap.roundAll,
                        backgroundColor: Theme.of(context).cursorColor,
                        progressColor: _colorBarMonth,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
