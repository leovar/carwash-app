import 'dart:core';

import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/ui/widgets/item_operator.dart';
import 'package:car_wash_app/invoice/ui/widgets/item_product.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class OperatorsInvoicePage extends StatefulWidget {
  final Function(List<User>) callbackSetOperatorsList;
  final Function() callbackFinishInvoice;
  List<User> usersListCallback;
  final bool editForm;
  final String idLocation;
  final bool closedInvoice;
  final bool fromCompleteInvoice;

  OperatorsInvoicePage({
    Key key,
    this.callbackSetOperatorsList,
    this.callbackFinishInvoice,
    this.usersListCallback,
    this.editForm,
    this.idLocation,
    this.closedInvoice,
    this.fromCompleteInvoice,
  });

  @override
  State<StatefulWidget> createState() => _OperatorsInvoicePage();
}

class _OperatorsInvoicePage extends State<OperatorsInvoicePage> {
  BlocInvoice _blocInvoice = BlocInvoice();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Operadores",
          style: TextStyle(
            fontFamily: "Lato",
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: listUsers(),
    );
  }

  Widget listUsers() {
    return StreamBuilder(
      stream: _blocInvoice.operatorsByLocationStream(widget.idLocation),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return showOperatorsWidget(snapshot);
        }
      },
    );
  }

  Widget showOperatorsWidget(AsyncSnapshot snapshot) {
    //widget.cbHandlerOperator('', _listUsersOperators.length, 2);   //Evaluarlo luego, esta función se usa para el select de un solo operador
    List<User> _listUsersOperators =
        _blocInvoice.buildOperators(snapshot.data.documents);
    List<User> _userGet = <User>[];
    _listUsersOperators.forEach((item) {
      User userFind = widget.usersListCallback.firstWhere(
          (element) => element.id == item.id && element.isSelected,
          orElse: () => null);
      if (userFind == null) {
        _userGet.add(item);
      } else {
        User userSelected = User.copyWith(
          origin: item,
          isSelected: true,
        );
        _userGet.add(userSelected);
      }
    });
    widget.usersListCallback = _userGet;

    return Column(
      children: [
        Flexible(
          child: ListView.builder(
            itemCount: widget.usersListCallback.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return ItemOperator(
                widget.callbackSetOperatorsList,
                widget.usersListCallback,
                index,
                widget.editForm,
                widget.closedInvoice,
                widget.fromCompleteInvoice,
              );
            },
          ),
        ),
        Container(
          height: 100,
          child: Align(
            alignment: Alignment.center,
            child: RaisedButton(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
              color: Color(0xFF59B258),
              child: Text(
                widget.fromCompleteInvoice ?? false ? "Terminar" : "Aceptar",
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 19,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                if (widget.fromCompleteInvoice ?? false) {
                  widget.callbackFinishInvoice();
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
