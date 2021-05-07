import 'dart:io';
import 'package:car_wash_app/widgets/messages_utils.dart';
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
import 'package:flutter/cupertino.dart';

class CustomersReport extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CustomersReport();
}

class _CustomersReport extends State<CustomersReport> {
  BlocReports _blocReports = BlocReports();
  BlocLocation _blocLocation = BlocLocation();
  BlocCustomer _blocCustomer = BlocCustomer();
  List<DropdownMenuItem<Location>> _dropdownMenuItems;
  Location _selectedLocation;

  DocumentReference _locationReference;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _filterParamsReport(),
        RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          color: Theme.of(context).accentColor,
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
          onPressed: _generateCustomerReport,
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
          Flexible(
            child: _locationsList(),
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
            return Center(
              child: CircularProgressIndicator(),
            );
          default:
            return _chargeDropLocations(snapshot);
        }
      },
    );
  }

  Widget _chargeDropLocations(AsyncSnapshot snapshot) {
    List<Location> locationList =
        _blocLocation.buildLocations(snapshot.data.documents);
    _dropdownMenuItems = builtDropdownMenuItems(locationList);

    return DropdownButton(
      isExpanded: true,
      items: _dropdownMenuItems,
      value: _selectedLocation,
      onChanged: onChangeDropDawn,
      hint: Text(
        "Seleccione la Sede...",
      ),
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: Theme.of(context).cardColor,
      ),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(
        fontFamily: "AvenirNext",
        fontWeight: FontWeight.normal,
        color: Theme.of(context).cardColor,
      ),
      underline: Container(
        height: 1,
        color: Theme.of(context).cursorColor,
      ),
    );
  }

  List<DropdownMenuItem<Location>> builtDropdownMenuItems(List locations) {
    List<DropdownMenuItem<Location>> listItems = List();
    for (Location documentLoc in locations) {
      listItems.add(
        DropdownMenuItem(
          value: documentLoc,
          child: Text(
            documentLoc.locationName,
          ),
        ),
      );
    }
    return listItems;
  }

  /// Functions
  onChangeDropDawn(Location selectedLocation) async {
    _locationReference =
        await _blocLocation.getLocationReference(selectedLocation.id);
    setState(() {
      _selectedLocation = selectedLocation;
    });
  }

  void _generateCustomerReport() async {
    if (_selectedLocation != null) {
      //Open message Saving
      MessagesUtils.showAlertWithLoading(
              context: context, title: 'Generando reporte')
          .show();
      List<Customer> _listCustomers = await _blocCustomer
          .getListCustomerReportByLocation(_locationReference);
      List<Customer> _newListCustomer = [];
      _newListCustomer = _listCustomers.toSet().toList();
      _newListCustomer.sort((a, b) => a.name.compareTo(b.name));

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
          "Sede"
        ];
        sheetObject.appendRow(header);
        _newListCustomer.forEach((item) {
          List<String> row = [
            "${item.name}",
            "${item.address}",
            "${item.phoneNumber}",
            "${item.email}",
            "${item.birthDate}",
            "${item.neighborhood}",
            "${item.typeSex}",
            "${_selectedLocation.locationName}"
          ];
          sheetObject.appendRow(row);
        });
      }

      excel.rename("Sheet1", "Hoja1");

      String outputFile =
          "/storage/emulated/0/Download/ReporteClientes_${_selectedLocation.locationName}.xlsx";
      excel.encode().then((onValue) {
        File(path_prov.join(outputFile))
          ..createSync(recursive: true)
          ..writeAsBytesSync(onValue);
      });
      Navigator.pop(context); //Close popUp Save
      Fluttertoast.showToast(
          msg: "Su reporte ha sido descargado en: ${outputFile}",
          toastLength: Toast.LENGTH_LONG);
    } else {
      Fluttertoast.showToast(
          msg: "Primero seleccione una sede", toastLength: Toast.LENGTH_LONG);
    }
  }
}
