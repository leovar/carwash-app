import 'dart:io';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/reports/bloc/bloc_reports.dart';
import 'package:car_wash_app/reports/model/earnings_card_detail.dart';
import 'package:car_wash_app/reports/ui/widgets/item_earning_card.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:excel/excel.dart' as excel_lib;
import 'package:path/path.dart' as path_prov;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class EarningsReport extends StatefulWidget {
  final String companyId;

  EarningsReport({Key? key, required this.companyId});

  @override
  State<StatefulWidget> createState() => _EarningsReport();
}

class _EarningsReport extends State<EarningsReport> {
  BlocReports _blocReports = BlocReports();

  List<EarningsCardDetail> _listCardReport = [];
  List<Invoice> _listInvoices = [];

  final _textDateInit = TextEditingController();
  final _textDateFinal = TextEditingController();
  var _dateTimeInit = DateTime(DateTime.now().year, DateTime.now().month, 1);
  var _dateTimeFinal = DateTime.now();
  var formatter = new DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _textDateInit.text = formatter.format(_dateTimeInit);
    _textDateFinal.text = formatter.format(_dateTimeFinal);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        _filterParamsReport(),
        SizedBox(height: 4.0),
        /*Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Descargar',
              style: TextStyle(
                color: Theme.of(context).accentColor,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.file_download,
                color: Theme.of(context).accentColor,
              ),
              iconSize: 32,
              onPressed: _downloadReport,
            ),
          ],
        ),
        SizedBox(
          height: 4.0,
        ),*/
        Expanded(child: _getDataReport()),
      ],
    );
  }

  Widget _filterParamsReport() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _textDateInit,
              decoration: InputDecoration(labelText: 'Fecha Desde'),
              keyboardType: TextInputType.datetime,
              readOnly: true,
              onTap: () {
                _datePickerFrom();
              },
            ),
          ),
          Flexible(
            child: TextField(
              controller: _textDateFinal,
              decoration: InputDecoration(labelText: 'Fecha Hasta'),
              keyboardType: TextInputType.datetime,
              readOnly: true,
              onTap: () {
                _datePickerFinal();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _getDataReport() {
    return StreamBuilder(
      stream: _blocReports.earningsReportListStream(
        _dateTimeInit,
        _dateTimeFinal,
        widget.companyId,
      ),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return _containerData(snapshot);
      },
    );
  }

  Widget _containerData(AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return Center(child: CircularProgressIndicator());
      default:
        if (snapshot.data != null) {
          _listInvoices = _blocReports.buildEarningsReportList(snapshot.data.docs);
          _listCardReport = _blocReports.buildEarningCards(_listInvoices);
          _listCardReport.sort((a, b) => a.locationName.compareTo(b.locationName));

          if (_listInvoices.length > 0) {
            return Container(
              padding: EdgeInsets.only(bottom: 17),
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_listCards(), _quantitySummary()],
              ),
            );
          } else {
            return _emptyLocation();
          }
        } else {
          return _emptyLocation();
        }
    }
  }

  Widget _listCards() {
    return Flexible(
      child: ListView.builder(
        itemCount: _listCardReport.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return ItemEarningCard(cardDetail: _listCardReport[index]);
        },
      ),
    );
  }

  Widget _quantitySummary() {
    final formatterPrice = NumberFormat("#,###");
    double _totalValue = 0;
    _listCardReport.forEach((item) {
      _totalValue = _totalValue + item.totalPrice;
    });

    return Container(
      margin: EdgeInsets.only(top: 8),
      padding: EdgeInsets.symmetric(vertical: 8), // add vertical padding instead of height
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFD8D8D8), width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                'Venta global empresa',
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontSize: 17.0,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.only(right: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '\$${formatterPrice.format(_totalValue)}',
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontWeight: FontWeight.w600,
                    fontSize: 17.0,
                    color: Color(0xFF59B258),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyLocation() {
    return Container(
      child: Center(child: Text('No hay información para mostrar')),
    );
  }

  /// Functions
  Future<Null> _datePickerFrom() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateTimeInit,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );

    if (picked != _dateTimeInit) {
      setState(() {
        if (picked != null) {
          _dateTimeInit = picked;
        }
        _textDateInit.text = formatter.format(_dateTimeInit);
      });
    }
  }

  Future<Null> _datePickerFinal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateTimeFinal,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );

    if (picked != _dateTimeFinal) {
      setState(() {
        if (picked != null) {
          _dateTimeFinal = picked;
        }
        _textDateFinal.text = formatter.format(_dateTimeFinal);
      });
    }
  }

  void _downloadReport() async {
    int count = 0;
    try {
      List<Invoice> _listInvoicesReport =
          _listInvoices
              .where((f) => !(f.cancelledInvoice??false) && (f.invoiceClosed??false))
              .toList();
      if (_listInvoicesReport.length > 0) {
        MessagesUtils.showAlertWithLoading(
          context: context,
          title: 'Generando reporte',
        ).show();

        int _maxCountOperators = 0;
        _listInvoicesReport.forEach((itemInvoice) {
          if ((itemInvoice.countOperators ?? 0) > _maxCountOperators)
            _maxCountOperators = itemInvoice.countOperators??0;
        });

        var excel = excel_lib.Excel.createExcel();
        var sheetObject = excel["Sheet1"];

        List<String> header = [
          "Fecha del servicio",
          "Sede",
          "Factura",
          "Valor total",
          "Comisión total del servicio",
          "Cantidad de operadores",
          "Comisión por operador",
          "Operadores",
        ];
        for (var i = 1; i <= _maxCountOperators; i++) {
          header.add("Operador " + i.toString());
        }
        sheetObject.appendRow(header.cast<excel_lib.CellValue?>());
        _listInvoicesReport.forEach((item) {
          count++;
          List<String> row = [
            "${formatter.format(item.creationDate!.toDate())}",
            "${item.locationName}",
            "${item.consecutive}",
            "${(item.totalPrice??0).toInt()}",
            "${item.totalCommission}",
            "${item.countOperators}",
            "${((item.totalCommission ?? 0) / (item.countOperators??0))}",
            "${item.operatorsSplit}",
          ];
          item.operatorUsers?.forEach((itemOpp) {
            row.add("${itemOpp.name}");
          });
          sheetObject.appendRow(row.cast<excel_lib.CellValue?>());
        });

        excel.rename("Sheet1", "Hoja1");

        String outputFile =
            "/storage/emulated/0/Download/ReporteGanancias.xlsx";
        var encodedExcel = await excel.encode();
        if (encodedExcel != null) {
          File(path_prov.join(outputFile))
            ..createSync(recursive: true)
            ..writeAsBytesSync(encodedExcel);
        }

        Navigator.pop(context); //Close popUp Save
        Fluttertoast.showToast(
          msg: "Su reporte ha sido descargado en: ${outputFile}",
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (_error) {
      print('$_error');
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Error generando el informe: Linea $count  $_error",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }
}
