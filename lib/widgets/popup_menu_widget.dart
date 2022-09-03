import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class PopUpMenuWidget extends StatefulWidget {
  String valueSelect;
  String popUpName = '';
  List<String> listString = <String>[];
  Function(String) selectValue;
  final bool enableForm;
  final bool editForm;

  PopUpMenuWidget({
    Key key,
    this.popUpName,
    this.selectValue,
    this.listString,
    this.valueSelect,
    this.enableForm,
    this.editForm,
  });

  @override
  State<StatefulWidget> createState() {
    return _PopUpMenuWidget();
  }
}

class _PopUpMenuWidget extends State<PopUpMenuWidget> {
  @override
  Widget build(BuildContext context) {
    if (!widget.listString.contains(widget.popUpName)) {
      //TODO se comenta la siguiente linea para que no agrege el nombre del control a la lista, validar si es necesario agregarlo 11/03/21
      //widget.listString.add(widget.popUpName);
    }
    if (widget.valueSelect.isEmpty) {
      widget.valueSelect = widget.popUpName;
    }

    return PopupMenuButton(
      enabled: widget.enableForm ?? true,
      color: Colors.white,
      itemBuilder: (BuildContext context) {
        return widget.listString.map((String valueList) {
          return PopupMenuItem<String>(
            value: valueList,
            child: Text(valueList),
          );
        }).toList();
      },
      onSelected: (String valText) {
        if (valText == widget.popUpName) {
          _selectValue('');
        } else {
          _selectValue(valText);
        }
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top: 5) ,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    widget.valueSelect,
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
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 30,
                    ),
                    onPressed: (){},
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
          Positioned(
              left: 10,
              top: 0,
              child: Container(
                padding: EdgeInsets.only(bottom: 2, left: 10, right: 10),
                color: Colors.white,
                child: Text(
                  widget.popUpName,
                  style: TextStyle(color: Color(0xFFAEAEAE), fontSize: 12),
                ),
              ),
          ),
        ],
      ),
    );
  }

  void _selectValue(String value) {
    setState(() {
      widget.valueSelect = value;
      widget.selectValue(value);
    });
  }
}
