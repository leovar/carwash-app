import 'package:car_wash_app/invoice/model/header_services.dart';
import 'package:flutter/material.dart';

class RadioItem extends StatelessWidget {
  final HeaderServices _item;

  RadioItem(this._item);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: (MediaQuery.of(context).size.width / 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: _item.isSelected ? Color(0xFF59B258) : Colors.white,
            width: 5.0,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: Container(
              width: _item.withImage,
              margin: EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(_item.isSelected
                        ? _item.imageSelected
                        : _item.imageUnselected)),
              ),
            ),
          ),
          Flexible(
            child: Text(
              _item.text,
              style: TextStyle(
                fontFamily: "Lato",
                fontWeight: FontWeight.w600,
                fontSize: _item.isSelected ? 16 : 15,
                color: _item.isSelected ? Color(0xFF59B258) : Color(0xFF27AEBB),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
