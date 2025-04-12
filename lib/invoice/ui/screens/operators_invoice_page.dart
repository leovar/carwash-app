import 'dart:core';

import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/ui/widgets/item_operator.dart';
import 'package:car_wash_app/user/model/sysUser.dart';
import 'package:flutter/material.dart';

class OperatorsInvoicePage extends StatefulWidget {
  final Function(List<SysUser>) callbackSetOperatorsList;
  final Function() callbackFinishInvoice;
  List<SysUser> usersListCallback;
  final bool editForm;
  final String idLocation;
  final bool closedInvoice;
  final bool fromCompleteInvoice;
  final Invoice? invoice;

  OperatorsInvoicePage({
    Key? key,
    required this.callbackSetOperatorsList,
    required this.callbackFinishInvoice,
    required this.usersListCallback,
    required this.editForm,
    required this.idLocation,
    required this.closedInvoice,
    required this.fromCompleteInvoice,
    this.invoice,
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
    if (widget.invoice != null && (widget.invoice?.invoiceClosed??false)) {
      List<SysUser> operatorsList = [];
      widget.usersListCallback.forEach((item) {
        SysUser userSelected = SysUser.copyWith(
          origin: item,
          isSelected: true,
        );
        operatorsList.add(userSelected);
      });
      widget.usersListCallback = operatorsList;
      return _showOperators();
    } else {
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
  }

  Widget showOperatorsWidget(AsyncSnapshot snapshot) {
    List<SysUser> _listUsersOperators = _blocInvoice.buildOperators(snapshot.data.docs);
    List<SysUser> _userGet = <SysUser>[];
    _listUsersOperators.forEach((item) {
      SysUser userFind = widget.usersListCallback.firstWhere(
          (element) => element.id == item.id && (element.isSelected??false),
          orElse: () => new SysUser(uid: '', name: '', email: ''));
      if (userFind.name.isEmpty) {
        _userGet.add(item);
      } else {
        SysUser userSelected = SysUser.copyWith(
          origin: item,
          isSelected: true,
        );
        _userGet.add(userSelected);
      }
    });
    _userGet.sort((a, b) => a.name.compareTo(b.name));
    widget.usersListCallback = _userGet;

    return _showOperators();
  }

  Widget _showOperators() {
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
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                backgroundColor: Color(0xFF59B258),
              ),
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
