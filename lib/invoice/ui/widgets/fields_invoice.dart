import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:flutter/material.dart';
import 'package:car_wash_app/invoice/ui/widgets/text_field_input.dart';
import 'package:car_wash_app/widgets/popup_menu_widget.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class FieldsInvoice extends StatefulWidget{

  final textPlaca;
  final textClient;
  final textEmail;
  bool sendEmail = false;
  final VoidCallback callbackSaveInvoice;
  final Function(String) setOperator;
  final Function(String) setCoordinator;
  List<String> listOperators;
  List<String> listCoordinators;

  FieldsInvoice({
    Key key,
    @required this.callbackSaveInvoice,
    this.textPlaca,
    this.sendEmail,
    this.textClient,
    this.textEmail,
    this.setOperator,
    this.setCoordinator,
    this.listOperators,
    this.listCoordinators,
  });

  @override
  State<StatefulWidget> createState() {
    return _FieldsInvoice();
  }
}

class _FieldsInvoice extends State<FieldsInvoice>{
  BlocInvoice _blocInvoice;
  @override
  Widget build(BuildContext context) {
    _blocInvoice = BlocProvider.of(context);
    return Column(
      children: <Widget>[
        TextFieldInput("Placa",
          widget.textPlaca,
        ),
        SizedBox(
          height: 9,
        ),
        TextFieldInput("Cliente",
          widget.textClient,
        ),
        SizedBox(
          height: 9,
        ),
        TextFieldInput("Correo Electrónico",
          widget.textEmail,
        ),
        SizedBox(
          height: 9,
        ),
        SizedBox(
          height: 9,
        ),
        Row(
          children: <Widget>[
            Checkbox(
              value: widget.sendEmail,
              onChanged: (bool value) {
                setState(() {
                  widget.sendEmail = value;
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
        getOperators(),
        SizedBox(
          height: 9,
        ),
        getCoordinators(),
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
              onPressed: widget.callbackSaveInvoice,
            ),
          ),
        ),
      ],
    );
  }

  Widget getOperators() {
    return StreamBuilder(
      stream: _blocInvoice.operatorsStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch(snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return showPopUpOperators(snapshot);
        }
      },
    );
  }
  Widget showPopUpOperators(AsyncSnapshot snapshot) {
    List<User> operatorsList = _blocInvoice.buildOperators(snapshot.data.documents);
    widget.listOperators = operatorsList.map((user) => user.name).toList();
    return PopUpMenuWidget(PopUpName: 'Operador', selectValue: widget.setOperator, listString: widget.listOperators,);
  }

  Widget getCoordinators() {
    return StreamBuilder(
      stream: _blocInvoice.coordinatorsStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch(snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return showPopUpCoordinators(snapshot);
        }
      },
    );
  }
  Widget showPopUpCoordinators(AsyncSnapshot snapshot) {
    List<User> coordinatorsList = _blocInvoice.buildCoordinators(snapshot.data.documents);
    widget.listCoordinators = coordinatorsList.map((user) => user.name).toList();
    return PopUpMenuWidget(PopUpName: 'Coordinador', selectValue: widget.setCoordinator, listString: widget.listCoordinators,);
  }

}
