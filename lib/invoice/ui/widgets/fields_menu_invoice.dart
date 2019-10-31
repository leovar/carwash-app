import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/widgets/popup_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class FieldsMenusInvoice extends StatefulWidget {
  final Function(String) setOperator;
  final Function(String) setCoordinator;
  List<String> listOperators;
  List<String> listCoordinators;
  final selectedOperator;
  final selectedCoordinator;
  final bool enableForm;

  FieldsMenusInvoice({Key key,
    this.setOperator,
    this.setCoordinator,
    this.listOperators,
    this.listCoordinators,
    this.selectedOperator,
    this.selectedCoordinator,
    this.enableForm
  });

  @override
  State<StatefulWidget> createState() {
    return _FieldsMenusInvoice();
  }
}

class _FieldsMenusInvoice extends State<FieldsMenusInvoice> {
  BlocInvoice _blocInvoice;

  @override
  Widget build(BuildContext context) {
    _blocInvoice = BlocProvider.of(context);
    return Column(
      children: <Widget>[
        getOperators(),
        SizedBox(
          height: 9,
        ),
        getCoordinators(),
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
    return PopUpMenuWidget(
      popUpName: 'Operador',
      selectValue: widget.setOperator,
      listString: widget.listOperators,
      valueSelect: widget.selectedOperator,
      enableForm: widget.enableForm,
    );
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
    return PopUpMenuWidget(
      popUpName: 'Coordinador',
      selectValue: widget.setCoordinator,
      listString: widget.listCoordinators,
      valueSelect: widget.selectedCoordinator,
      enableForm: widget.enableForm,
    );
  }

}