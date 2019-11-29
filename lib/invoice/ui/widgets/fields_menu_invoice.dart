import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/widgets/popup_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class FieldsMenusInvoice extends StatefulWidget {
  final int listCountOperators;
  final int listCountCoordinators;
  final Function(String) setOperator;
  final Function(String) setCoordinator;
  final Function(List<User>) cbSetOperatorsList;
  final Function(List<User>) cbSetCoordinatorsList;
  final selectedOperator;
  final selectedCoordinator;
  final locationReference;
  final bool enableForm;
  final bool editForm;

  FieldsMenusInvoice({
    Key key,
    this.listCountOperators,
    this.listCountCoordinators,
    this.setOperator,
    this.setCoordinator,
    this.cbSetOperatorsList,
    this.cbSetCoordinatorsList,
    this.selectedOperator,
    this.selectedCoordinator,
    this.locationReference,
    this.enableForm,
    this.editForm,
  });

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
    //El contador inicial arranca en 0, al consultra los usuarios operadores por primera vez
    // ya queda cargado con la cantidad de usuarios encontrados y no tiene que volver a hacer la consulta
    // cada vez que hace un set state.
    if (widget.listCountCoordinators == 0) {
      return StreamBuilder(
        stream: _blocInvoice.operatorsStream(widget.locationReference),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              return showPopUpOperators(snapshot);
          }
        },
      );
    } else {
      return getOperatorsFromSimpleConsult();
    }
  }

  Widget showPopUpOperators(AsyncSnapshot snapshot) {
    _listUsersOperators = _blocInvoice.buildOperators(snapshot.data.documents);
    _listOperators = _listUsersOperators.map((user) => user.name).toList();
    widget.cbSetOperatorsList(_listUsersOperators);
    return chargeOperatorsControl();
  }

  Widget chargeOperatorsControl() {
    return PopUpMenuWidget(
      popUpName: 'Operador',
      selectValue: widget.setOperator,
      listString: _listOperators,
      valueSelect: widget.selectedOperator,
      enableForm: widget.enableForm,
      editForm: widget.editForm,
    );
  }

  Widget getOperatorsFromSimpleConsult() {
    return PopUpMenuWidget(
      popUpName: 'Operador',
      selectValue: widget.setOperator,
      listString: _listOperators,
      valueSelect: widget.selectedOperator,
      enableForm: widget.enableForm,
      editForm: widget.editForm,
    );
  }

  Widget getCoordinators() {
    if (widget.listCountCoordinators == 0) {
      return StreamBuilder(
        stream: _blocInvoice.coordinatorsStream(widget.locationReference),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              return showPopUpCoordinators(snapshot);
          }
        },
      );
    } else {
      return chargeCoordinatorsWidget();
    }
  }

  Widget showPopUpCoordinators(AsyncSnapshot snapshot) {
    _listUsersCoordinators =
        _blocInvoice.buildCoordinators(snapshot.data.documents);
    _listCoordinators =
        _listUsersCoordinators.map((user) => user.name).toList();
    widget.cbSetCoordinatorsList(_listUsersCoordinators);
    return chargeCoordinatorsWidget();
  }

  Widget chargeCoordinatorsWidget() {
    return PopUpMenuWidget(
      popUpName: 'Coordinador',
      selectValue: widget.setCoordinator,
      listString: _listCoordinators,
      valueSelect: widget.selectedCoordinator,
      enableForm: widget.enableForm,
    );
  }
}
