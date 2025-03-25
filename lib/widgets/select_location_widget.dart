import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:flutter/material.dart';

class SelectLocationWidget extends StatefulWidget {
  final Function(Location) selectLocation;
  final Location locationSelected;

  SelectLocationWidget({Key? key, required this.locationSelected, required this.selectLocation});

  @override
  State<StatefulWidget> createState() => _SelectLocationWidget();
}

class _SelectLocationWidget extends State<SelectLocationWidget> {
  BlocLocation _blocLocation = BlocLocation();
  late List<DropdownMenuItem<Location>> _dropdownMenuItems;
  late Location _selectedLocation;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.locationSelected;
    }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _getLocationsList(),
      ],
    );
  }

  Widget _getLocationsList() {
    return StreamBuilder(
      stream: _blocLocation.locationsStream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
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
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  List<DropdownMenuItem<Location>> builtDropdownMenuItems(List locations) {
    List<DropdownMenuItem<Location>> listItems = [];
    for (Location documentLoc in locations) {
      listItems.add(
        DropdownMenuItem(
          value: documentLoc,
          child: Text(
            documentLoc.locationName ?? '',
          ),
        ),
      );
    }
    return listItems;
  }

  onChangeDropDawn(Location? selectedLocation) {
    setState(() {
      widget.selectLocation(selectedLocation ?? new Location());
      _selectedLocation = selectedLocation ?? new Location();
    });
  }
}
