import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/location/ui/widgets/item_location.dart';
import 'package:flutter/material.dart';

class LocationsSelectListPage extends StatefulWidget {
  Function(List<Location>) callbackSetLocationsList;
  List<Location> locationsList;

  LocationsSelectListPage({
    Key? key,
    required this.callbackSetLocationsList,
    required this.locationsList,
  });

  @override
  State<StatefulWidget> createState() {
    return _LocationsSelectListPage();
  }
}

class _LocationsSelectListPage extends State<LocationsSelectListPage> {
  List<Location> locationGet = <Location>[];

  @override
  void initState() {
    super.initState();
    locationGet = widget.locationsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Servicios",
          style: TextStyle(
            fontFamily: "Lato",
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: listLocations(),
    );
  }

  Widget listLocations() {
    if (widget.locationsList.length > 0) {
      widget.locationsList.forEach((f) {
        if (f.isSelected??false) {
          locationGet[locationGet.indexWhere((p) => p.id == f.id)].isSelected =
              true;
        }
      });
      widget.locationsList = locationGet;
    }
    widget.locationsList = locationGet;

    return Column(
      children: <Widget>[
        Flexible(
          child: ListView.builder(
            itemCount: widget.locationsList.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return ItemLocation(
                  widget.callbackSetLocationsList, widget.locationsList, index);
            },
          ),
        ),
        Container(
          height: 100,
          child: Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
                backgroundColor: Color(0xFF59B258),
              ),
              child: Text(
                "Aceptar",
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 19,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ],
    );
  }
}
