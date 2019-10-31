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

  PopUpMenuWidget({
    Key key,
    this.popUpName,
    this.selectValue,
    this.listString,
    this.valueSelect,
    this.enableForm,
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
      widget.listString.add(widget.popUpName);
    }
    print(widget.valueSelect);
    if (widget.valueSelect.isEmpty) {
      widget.valueSelect = widget.popUpName;
    }

    return PopupMenuButton(
      enabled: widget.enableForm?? true,
      itemBuilder: (BuildContext context) {
        return widget.listString.map((String valueList) {
          return PopupMenuItem<String>(
            value: valueList,
            child: Text(valueList),
          );
        }).toList();
      },
      onSelected: (String valText) {
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

  void _selectValue(String value) {
    setState(() {
      widget.valueSelect = value;
      widget.selectValue(value);
    });
  }
}
