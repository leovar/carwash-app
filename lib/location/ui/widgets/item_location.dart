import 'package:car_wash_app/location/model/location.dart';
import 'package:flutter/material.dart';

class ItemLocation extends StatefulWidget {
  Function(List<Location>) locationListCallback;
  List<Location> locationList;
  int index;

  ItemLocation(this.locationListCallback, this.locationList, this.index);

  @override
  State<StatefulWidget> createState() => _ItemLocation();
}

class _ItemLocation extends State<ItemLocation> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.white,
      onTap: () {
        setState(() {
          if (widget.locationList[widget.index].isSelected) {
            widget.locationList[widget.index].isSelected = false;
          } else {
            widget.locationList[widget.index].isSelected = true;
          }
          widget.locationListCallback(widget.locationList);
        });
      },
      child: itemDecoration(widget.locationList[widget.index]),
    );
  }

  Widget itemDecoration(Location _itemLocation) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 70.0
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: _itemLocation.isSelected ? Color(0xFFF1F1F1) : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFD8D8D8),
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10),
              width: 30,
              child: _itemLocation.isSelected
                  ? Icon(
                Icons.check,
                color: Color(0xFF59B258),
                size: 35,
              )
                  : null,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 15),
                child: Text(
                  _itemLocation.locationName,
                  style: TextStyle(
                    fontFamily: "Lato",
                    decoration: TextDecoration.none,
                    color: Color(0xFFAEAEAE),
                    fontSize: 21,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
