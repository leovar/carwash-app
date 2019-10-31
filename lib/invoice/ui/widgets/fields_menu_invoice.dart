import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/widgets/popup_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class FieldsMenusInvoice extends StatefulWidget {
  final Function(String) setOperator;
  final Function(String) setCoordinator;
  final Function(List<User>) cbSetOperatorsList;
  final Function(List<User>) cbSetCoordinatorsList;
  final selectedOperator;
  final selectedCoordinator;
  final bool enableForm;

  FieldsMenusInvoice(
      {Key key,
      this.setOperator,
      this.setCoordinator,
      this.cbSetOperatorsList,
      this.cbSetCoordinatorsList,
      this.selectedOperator,
      this.selectedCoordinator,
      this.enableForm});

  @override
  State<StatefulWidget> createState() {
    return _FieldsMenusInvoice();
  }
}

class _FieldsMenusInvoice extends State<FieldsMenusInvoice> {
  BlocInvoice _blocInvoice;
  List<User> _listUsersOperators;
  List<User> _listUsersCoordinators;
  List<String> _listOperators = <String>[];
  List<String> _listCoordinators = <String>[];

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
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return showPopUpOperators(snapshot);
        }
      },
    );
  }

  Widget showPopUpOperators(AsyncSnapshot snapshot) {
    _listUsersOperators = _blocInvoice.buildOperators(snapshot.data.documents);
    _listOperators = _listUsersOperators.map((user) => user.name).toList();
    widget.cbSetOperatorsList(_listUsersOperators);
    return PopUpMenuWidget(
      popUpName: 'Operador',
      selectValue: widget.setOperator,
      listString: _listOperators,
      valueSelect: widget.selectedOperator,
      enableForm: widget.enableForm,
    );
  }

  Widget getCoordinators() {
    return StreamBuilder(
      stream: _blocInvoice.coordinatorsStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return showPopUpCoordinators(snapshot);
        }
      },
    );
  }

  Widget showPopUpCoordinators(AsyncSnapshot snapshot) {
    _listUsersCoordinators =
        _blocInvoice.buildCoordinators(snapshot.data.documents);
    _listCoordinators =
        _listUsersCoordinators.map((user) => user.name).toList();
    widget.cbSetCoordinatorsList(_listUsersCoordinators);
    return PopUpMenuWidget(
      popUpName: 'Coordinador',
      selectValue: widget.setCoordinator,
      listString: _listCoordinators,
      valueSelect: widget.selectedCoordinator,
      enableForm: widget.enableForm,
    );
  }
}
