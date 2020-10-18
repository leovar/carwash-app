import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/reports/bloc/bloc_reports.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProductivityReport extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProductivityReport();
}

class _ProductivityReport extends State<ProductivityReport> {
  BlocReports _blocReports  = BlocReports();
  BlocLocation _blocLocation = BlocLocation();
  List<DropdownMenuItem<Location>> _dropdownMenuItems;
  Location _selectedLocation;

  final _textDateInit = TextEditingController();
  final _textDateFinal = TextEditingController();
  var _dateTimeInit = DateTime(DateTime.now().year, DateTime.now().month, 1);
  var _dateTimeFinal = DateTime.now();
  DocumentReference _locationReference;
  var formatter = new DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _textDateInit.text = formatter.format(_dateTimeInit);
    _textDateFinal.text = formatter.format(_dateTimeFinal);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      scrollDirection: Axis.vertical,
      children: <Widget>[
        _filterParamsReport(),
        SizedBox(
          height: 10.0,
        ),
        _getDataReport(),
      ],
    );
  }

  Widget _filterParamsReport() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: _locationsList(),
          ),
          Flexible(
            child: TextField(
              controller: _textDateInit,
              decoration: InputDecoration(
                labelText: 'Fecha Desde',
              ),
              keyboardType: TextInputType.datetime,
              readOnly: true,
              onTap: (){
                _datePickerFrom();
              },
            ),
          ),
          Flexible(
            child: TextField(
              controller: _textDateFinal,
              decoration: InputDecoration(
                labelText: 'Fecha Hasta',
              ),
              keyboardType: TextInputType.datetime,
              readOnly: true,
              onTap: (){
                _datePickerFinal();
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _getDataReport() {
    return StreamBuilder(
      stream: _blocReports.productivityReportListStream(
        _locationReference,
        _dateTimeInit,
        _dateTimeFinal,
      ),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return _containerList(snapshot);
      },
    );
  }

  Widget _containerList(AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        break;
      default:
        final _listInvoices = _blocReports.buildProductivityReportList(snapshot.data.documents);
        _listInvoices.sort((a, b) => b.consecutive.compareTo(a.consecutive));
    }

    return Container();
  }

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

  /// Locations filter section
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
    _locationReference = await _blocLocation.getLocationReference(selectedLocation.id);
    setState(() {
      _selectedLocation = selectedLocation;
    });
  }

  Future<Null> _datePickerFrom() async {
    final DateTime picked = await showDatePicker(context: context,
      initialDate: _dateTimeInit,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _dateTimeInit) {
      setState(() {
        _dateTimeInit = picked;
        _textDateInit.text = formatter.format(_dateTimeInit);
      });
    }
  }

  Future<Null> _datePickerFinal() async {
    final DateTime picked = await showDatePicker(context: context,
      initialDate: _dateTimeFinal,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _dateTimeFinal) {
      setState(() {
        _dateTimeFinal = picked;
        _textDateFinal.text = formatter.format(_dateTimeFinal);
      });
    }
  }


}
