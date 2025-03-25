import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/location/ui/widgets/item_location_admin_list.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

import 'create_location_admin_page.dart';

class LocationsAdminPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _LocationsAdminPage();
}

class _LocationsAdminPage extends State<LocationsAdminPage> {
  late BlocLocation _locationsBloc;
  List<Location> _locationList = <Location>[];

  @override
  Widget build(BuildContext context) {
    _locationsBloc = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Sedes",
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
      body: SafeArea(
        child: _bodyContainer(),
      ),
    );
  }

  Widget _bodyContainer() {
    return Container(
      padding: EdgeInsets.only(bottom: 17),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _listLocationsStream(),
          _buttonNewUser(),
        ],
      ),
    );
  }

  Widget _listLocationsStream() {
    return StreamBuilder(
      stream: _locationsBloc.allLocationsStream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
              return _getDataLocationsList(snapshot);
        }
      },
    );
  }

  Widget _getDataLocationsList(AsyncSnapshot snapshot) {
    _locationList = _locationsBloc.buildAllLocations(snapshot.data.documents);
    return Flexible(
      child: ListView.builder(
        itemCount: _locationList.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return ItemLocationAdminList(_locationList, index);
        },
      ),
    );
  }

  Widget _buttonNewUser() {
    return Container(
      height: 60,
      margin: EdgeInsets.only(top: 8,),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
            backgroundColor: Color(0xFF59B258),
          ),
          child: Text(
            "Nueva Sede",
            style: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 19,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return BlocProvider(
                    bloc: BlocLocation(),
                    child: CreateLocationAdminPage(),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}