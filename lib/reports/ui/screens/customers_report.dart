import 'dart:io';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path_prov;
import 'package:car_wash_app/customer/bloc/bloc_customer.dart';
import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/reports/bloc/bloc_reports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';

class CustomersReport extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CustomersReport();
}

class _CustomersReport extends State<CustomersReport> {
  BlocReports _blocReports = BlocReports();
  BlocLocation _blocLocation = BlocLocation();
  BlocCustomer _blocCustomer = BlocCustomer();
  late List<DropdownMenuItem<Location>> _dropdownMenuItems;
  Location _selectedLocation = new Location();

  final _textDateInit = TextEditingController();
  final _textDateFinal = TextEditingController();
  DocumentReference _locationReference = FirebaseFirestore.instance.collection('locations').doc('defaultDocId');
  var formatter = new DateFormat('dd-MM-yyyy');
  var _dateTimeInit = DateTime(DateTime.now().year, DateTime.now().month, 1);
  var _dateTimeFinal = DateTime.now();

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
      children: <Widget>[
        _filterParamsReport(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          ),
          child: Text(
            "GENERAR EXCEL",
            style: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 19,
            ),
          ),
          onPressed: _generateInvoiceCustomerReport,
        ),
      ],
    );
  }

  Widget _filterParamsReport() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(child: _locationsList()),
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

  /// Locations filter section
  Widget _locationsList() {
    return StreamBuilder(
      stream: _blocLocation.locationsStream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            return _chargeDropLocations(snapshot);
        }
      },
    );
  }

  Widget _chargeDropLocations(AsyncSnapshot snapshot) {
    List<Location> locationList = _blocLocation.buildLocations(
      snapshot.data.docs,
    );
    _dropdownMenuItems = builtDropdownMenuItems(locationList);

    return DropdownButton(
      isExpanded: true,
      items: _dropdownMenuItems,
      value: _selectedLocation,
      onChanged: onChangeDropDawn,
      hint: Text("Seleccione la Sede..."),
      icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).cardColor),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(
        fontFamily: "AvenirNext",
        fontWeight: FontWeight.normal,
        color: Theme.of(context).cardColor,
      ),
      underline: Container(height: 1, color: Theme.of(context).textSelectionTheme.cursorColor),
    );
  }

  List<DropdownMenuItem<Location>> builtDropdownMenuItems(List locations) {
    List<DropdownMenuItem<Location>> listItems = [];
    if (_selectedLocation.id == null) {
      listItems.add(
        DropdownMenuItem(
          value: _selectedLocation,
          child: Text('Todas las sedes'),
        ),
      );
    } else {
      listItems.add(
        DropdownMenuItem(
          value: new Location(),
          child: Text('Todas las sedes'),
        ),
      );
    }
    for (Location documentLoc in locations) {
      listItems.add(
        DropdownMenuItem(
          value: documentLoc,
          child: Text(documentLoc.locationName??''),
        ),
      );
    }
    return listItems;
  }

  /// Functions
  onChangeDropDawn(Location? selectedLocation) async {
    if (selectedLocation?.id?.isNotEmpty??false) {
      _locationReference = await _blocLocation.getLocationReference(
        selectedLocation?.id??'',
      );
      setState(() {
        if (selectedLocation !=  null) {
          _selectedLocation = selectedLocation;
        }
      });
    } else {
      _locationReference = FirebaseFirestore.instance.collection('locations').doc('defaultDocId');
      setState(() {
        _selectedLocation = selectedLocation ?? new Location();
      });
    }
  }

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

  void _generateInvoiceCustomerReport() async {
    try {
      MessagesUtils.showAlertWithLoading(
        context: context,
        title: 'Generando reporte',
      ).show();
      List<Invoice> _listInvoices = await _blocReports.getListCustomerInvoicesByLocation(
        _locationReference,
        _dateTimeInit,
        _dateTimeFinal,
      );

      if (_listInvoices.isNotEmpty) {
        List<Invoice> _newListInvoices = [];
        _newListInvoices = _listInvoices.toSet().toList();
        _newListInvoices.sort((a, b) => (a.customerName??'').compareTo(b.customerName??''));

        var excel = Excel.createExcel();
        var sheetObject = excel["Sheet1"];

        if (_newListInvoices.length > 0) {
          List<String> header = [
            "Número de factura",
            "Nombre",
            "Teléfono",
            "Fecha del servicio",
            "Valor",
            "Placa",
            "Sede",
            "Servicios",
            "Método de pago",
            "Sede",
          ];
          sheetObject.appendRow(header.map((e) => TextCellValue(e)).toList());
          _newListInvoices.forEach((item) {
            List<CellValue> row = [
              TextCellValue(item.consecutive?.toString()??''),
              TextCellValue(item.customerName ?? ''),
              TextCellValue(item.phoneNumber ?? ''),
              TextCellValue(
                item.creationDate != null
                    ? formatter.format(item.creationDate!.toDate())
                    : '',
              ),
              IntCellValue(item.totalPrice?.toInt() ?? 0),
              TextCellValue(item.placa ?? ''),
              TextCellValue(item.locationName ?? ''),
              TextCellValue(item.productsSplit ?? ''),
              TextCellValue(item.paymentMethod ?? ''),
              TextCellValue(item.locationName ?? ''),
            ];
            sheetObject.appendRow(row.cast<CellValue?>());
          });
        }

        excel.rename("Sheet1", "Hoja1");

        String outputFile = "/storage/emulated/0/Download/ReporteClientes_${_selectedLocation.locationName == null ? 'Todas las sedes' : _selectedLocation.locationName}.xlsx";
        var encodedExcel = await excel.encode();
        if (encodedExcel != null) {
          File(path_prov.join(outputFile))
            ..createSync(recursive: true)
            ..writeAsBytesSync(encodedExcel);
        } else {
          print("Error: Failed to encode Excel file.");
        }

        Navigator.pop(context); //Close popUp Save
        Fluttertoast.showToast(
          msg: "Su reporte ha sido descargado en: ${outputFile}",
          toastLength: Toast.LENGTH_LONG,
        );
      } else {
        MessagesUtils.showAlert(
          context: context,
          title: 'No hay datos para mostrar',
        );
      }
    } catch (error) {
      print('$error');
      Navigator.pop(context);
      MessagesUtils.showAlert(
        context: context,
        title: 'Error al generar el reporte',
      );
    }
  }

  void _generateCustomerReport() async {
    //Open message Saving
    MessagesUtils.showAlertWithLoading(
      context: context,
      title: 'Generando reporte',
    ).show();
    List<Customer> _listCustomers = await _blocCustomer
        .getListCustomerReportByLocation(_locationReference);
    List<Customer> _newListCustomer = [];
    _newListCustomer = _listCustomers.toSet().toList();
    _newListCustomer.sort((a, b) => (a.name??'').compareTo(b.name??''));
    var excel = Excel.createExcel();
    var sheetObject = excel["Sheet1"];

    if (_newListCustomer.length > 0) {
      List<String> header = [
        "Nombre",
        "Dirección",
        "Teléfono",
        "Correo",
        "Fecha de cumpleaños",
        "Barrio",
        "Genero",
        "Sede",
      ];
      sheetObject.appendRow(header.cast<CellValue?>());
      _newListCustomer.forEach((item) {
        List<String> row = [
          "${item.name}",
          "${item.address}",
          "${item.phoneNumber}",
          "${item.email}",
          "${item.birthDate}",
          "${item.neighborhood}",
          "${item.typeSex}",
          "${_selectedLocation.locationName}",
        ];
        sheetObject.appendRow(row.cast<CellValue?>());
      });
    }

    excel.rename("Sheet1", "Hoja1");

    String outputFile =
        "/storage/emulated/0/Download/ReporteClientes_${_selectedLocation.locationName}.xlsx";
    var encodedExcel = await excel.encode();
    if (encodedExcel != null) {
      File(path_prov.join(outputFile))
        ..createSync(recursive: true)
        ..writeAsBytesSync(encodedExcel);
    } else {
      print("Error: Failed to encode Excel file.");
    }

    Navigator.pop(context); //Close popUp Save
    Fluttertoast.showToast(
      msg: "Su reporte ha sido descargado en: ${outputFile}",
      toastLength: Toast.LENGTH_LONG,
    );
    }
}
