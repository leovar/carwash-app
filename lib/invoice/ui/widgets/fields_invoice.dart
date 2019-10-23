import 'package:flutter/material.dart';
import 'package:car_wash_app/invoice/ui/widgets/text_field_input.dart';
import 'package:car_wash_app/widgets/popup_menu_widget.dart';

class FieldsInvoice extends StatefulWidget{

  final Function(String, String) callbackSaveInvoice;

  FieldsInvoice({Key key, @required this.callbackSaveInvoice});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FieldsInvoice();
  }
}

class _FieldsInvoice extends State<FieldsInvoice>{

  bool _sendEmail = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: <Widget>[
        TextFieldInput("Placa"),
        SizedBox(
          height: 9,
        ),
        TextFieldInput("Cliente"),
        SizedBox(
          height: 9,
        ),
        TextFieldInput("Correo Electrónico"),
        SizedBox(
          height: 9,
        ),
        SizedBox(
          height: 9,
        ),
        Row(
          children: <Widget>[
            Checkbox(
              value: _sendEmail,
              onChanged: (bool value) {
                setState(() {
                  _sendEmail = value;
                });
              },
              checkColor: Colors.white,
              activeColor: Color(0xFF59B258),
            ),
            Text(
              "Enviar por correo electrónico",
              style: TextStyle(
                fontFamily: "Lato",
                decoration: TextDecoration.none,
                color: Color(0xFFAEAEAE),
                fontSize: 15,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 9,
        ),
        PopUpMenuWidget("Operador"),
        /*DropdownButton<String>(
            isExpanded: true,
            items: _operadores.map((String dropDawnStringItem) {
              return DropdownMenuItem<String>(
                value: dropDawnStringItem,
                child: Text(
                  dropDawnStringItem,
                  style: TextStyle(
                    color: Color(0xFFAEAEAE),
                  ),
                ),
              );
            }).toList(),
            onChanged: (String newValue) {
              setState(() {
                _currenOperatorSelected = newValue;
              });
            },
            value: _currenOperatorSelected,
          ),*/
        SizedBox(
          height: 9,
        ),
        PopUpMenuWidget("Coordinador"),
        /*DropdownButton<String>(
            isExpanded: true,
            items: _coordinadores.map((String dropDawnStringItem) {
              return DropdownMenuItem<String>(
                value: dropDawnStringItem,
                child: Text(
                  dropDawnStringItem,
                  style: TextStyle(
                    color: Color(0xFFAEAEAE),
                  ),
                ),
              );
            }).toList(),
            onChanged: (String newValue) {
              setState(() {
                _currenCoordinadorSelected = newValue;
              });
            },
            value: _currenCoordinadorSelected,
          ),*/
        SizedBox(
          height: 9,
        ),
        Container(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  "2 servicios agregados",
                  style: TextStyle(
                    fontFamily: "Lato",
                    decoration: TextDecoration.none,
                    color: Color(0xFF59B258),
                    fontSize: 17,
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
            color: Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        SizedBox(
          height: 9,
        ),
        Container(
          height: 90,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: <Widget>[
              FloatingActionButton(
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30,
                ),
                backgroundColor: Color(0xFFCCCCCC),
                onPressed: () {},
                heroTag: null,
              ),
              Container(
                margin: EdgeInsets.only(left: 15),
                child: Text(
                  "Agregar Servicios",
                  style: TextStyle(
                    fontFamily: "Lato",
                    decoration: TextDecoration.none,
                    color: Color(0xFFAEAEAE),
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFD8D8D8),
                width: 1.0,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 9,
        ),
        Container(
          height: 100,
          child: Align(
            alignment: Alignment.center,
            child: RaisedButton(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
              color: Color(0xFF59B258),
              child: Text(
                "GUARDAR",
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 19,
                ),
              ),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }

}
