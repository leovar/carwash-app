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
  final Function(String) setOperator;
  final Function(String) setCoordinator;
  List<String> listOperators;
  List<String> listCoordinators;

  FieldsInvoice({
    Key key,
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
