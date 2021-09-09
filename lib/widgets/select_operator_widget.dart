import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SelectOperatorWidget extends StatefulWidget {
  final Function(User) selectOperator;
  final User operatorSelected;
  final String idLocation;

  SelectOperatorWidget({
    Key key,
    this.operatorSelected,
    this.selectOperator,
    this.idLocation,
  });

  @override
  State<StatefulWidget> createState() => _SelectOperatorWidget();
}

class _SelectOperatorWidget extends State<SelectOperatorWidget> {
  BlocInvoice _blocInvoice = BlocInvoice();
  List<DropdownMenuItem<User>> _dropdownMenuItems;
  User _selectedUser;

  @override
  void initState() {
    super.initState();
    if (widget.operatorSelected.name != null && widget.operatorSelected.name != '') {
      _selectedUser = widget.operatorSelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _getOperatorsList(),
      ],
    );
  }

  Widget _getOperatorsList() {
    return StreamBuilder(
      stream: _blocInvoice.operatorsByLocationStream(widget.idLocation),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return _chargeDropOperators(snapshot);
        }
      },
    );
  }

  Widget _chargeDropOperators(AsyncSnapshot snapshot) {
    List<User> operatorsList =
        _blocInvoice.buildOperators(snapshot.data.documents);
    _dropdownMenuItems = builtDropdownMenuItems(operatorsList);

    return DropdownButton(
      isExpanded: true,
      items: _dropdownMenuItems,
      value: _selectedUser,
      onChanged: onChangeDropDawn,
      hint: Text(
        "Seleccione el operador...",
      ),
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: Theme.of(context).cardColor,
      ),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(
        fontFamily: "AvenirNext",
        fontWeight: FontWeight.normal,
        color: Theme.of(context).cardColor,
      ),
      underline: Container(
        height: 1,
        color: Theme.of(context).cursorColor,
      ),
    );
  }

  List<DropdownMenuItem<User>> builtDropdownMenuItems(List operators) {
    List<DropdownMenuItem<User>> listItems = List();
    for (User documentOpe in operators) {
      listItems.add(
        DropdownMenuItem(
          value: documentOpe,
          child: Text(
            documentOpe.name,
          ),
        ),
      );
    }
    return listItems;
  }

  onChangeDropDawn(User selectedUser) {
    setState(() {
      widget.selectOperator(selectedUser);
      _selectedUser = selectedUser;
    });
  }
}
