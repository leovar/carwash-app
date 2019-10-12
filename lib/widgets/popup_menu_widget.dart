import 'package:flutter/material.dart';

class PopUpMenuWidget extends StatefulWidget {

  String _valueSelect = "0";
  String _PopUpName = "";

  PopUpMenuWidget(this._PopUpName);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _PopUpMenuWidget();
  }
}

class _PopUpMenuWidget extends State<PopUpMenuWidget> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Text(widget._PopUpName),
        ),
        PopupMenuItem(
          value: 1,
          child: Text("First"),
        ),
        PopupMenuItem(
          value: 2,
          child: Text("Second"),
        ),
      ],
      onSelected: (valText) {
        print("value:$valText");
        _selectValue(valText);
      },
      child: Container(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                widget._valueSelect == "" || widget._valueSelect == "0" ? widget._PopUpName : widget._valueSelect,
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  color: Color(0xFFAEAEAE),
                  fontSize: 15,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.keyboard_arrow_down, size: 30,),
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.2,
            color: Color(0xFFAEAEAE),
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  void _selectValue(var value) {
    setState(() {
      widget._valueSelect = "${value}";
    });
  }

}
