import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class FilterFieldsWidget extends StatefulWidget {
  final TextEditingController placaController;
  final TextEditingController consecutiveController;
  final DateTime dateInit;
  final DateTime dateFinal;
  final User operatorSelected;
  final Function(User) selectOperator;
  final Function(DateTime) selectDateInit;
  final Function(DateTime) selectDateFinal;

  FilterFieldsWidget({Key key,
    this.placaController,
    this.consecutiveController,
    this.dateInit,
    this.dateFinal,
    this.operatorSelected,
    this.selectOperator,
    this.selectDateInit,
    this.selectDateFinal,
  });

  @override
  State<StatefulWidget> createState() => _FilterFieldsWidget();
}

class _FilterFieldsWidget extends State<FilterFieldsWidget> {
  BlocInvoice _blocInvoice =  BlocInvoice();
  final _textDateInit = TextEditingController();
  final _textDateFinal = TextEditingController();
  List<DropdownMenuItem<User>> _dropdownMenuItems;
  User _selectedOperator;
  DateTime _dateTimeInit;
  DateTime _dateTimeFinal;
  var formatter = new DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    if(widget.operatorSelected.name != null) {
      _selectedOperator = widget.operatorSelected;
    }
    _dateTimeInit = widget.dateInit;
    _dateTimeFinal = widget.dateFinal;
    _textDateInit.text = formatter.format(_dateTimeInit);
    _textDateFinal.text = formatter.format(_dateTimeFinal);
  }

  @override
  Widget build(BuildContext context) {
    //_blocInvoice = BlocProvider.of(context);
    return Column(
      children: <Widget>[
        TextField(
          controller: widget.placaController,
          decoration: InputDecoration(
            //icon: Icon(Icons.account_circle),
            labelText: 'Placa',
          ),
          inputFormatters: [
            WhitelistingTextInputFormatter(RegExp("^[a-zA-Z0-9]*"))
          ],
          textCapitalization: TextCapitalization.characters,
        ),
        SizedBox(height: 10),
        _getOperators(),
        SizedBox(height: 10),
        _selectDateInit(),
        SizedBox(height: 10),
        _selectDateFinal(),
        SizedBox(height: 10),
        TextField(
          controller: widget.consecutiveController,
          decoration: InputDecoration(
            //icon: Icon(Icons.account_circle),
            labelText: 'Consecutivo',
          ),
          inputFormatters: [
            WhitelistingTextInputFormatter(RegExp("^[0-9]*"))
          ],
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _selectDateInit(){
    return TextField(
      controller: _textDateInit,
      decoration: InputDecoration(
        labelText: 'Fecha Desde',
      ),
      keyboardType: TextInputType.datetime,
      readOnly: true,
      onTap: (){
        _datePickerFrom();
      },
    );
  }

  Widget _selectDateFinal() {
    return TextField(
      controller: _textDateFinal,
      decoration: InputDecoration(
        labelText: 'Fecha Hasta',
      ),
      keyboardType: TextInputType.datetime,
      readOnly: true,
      onTap: (){
        _datePickerFinal();
      },
    );
  }

  Widget _getOperators() {
    return StreamBuilder(
      stream: _blocInvoice.operatorsStream(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return _showOperators(snapshot);
        }
      },
    );
  }

  Widget _showOperators(AsyncSnapshot snapshot) {
    var userSelectionEmpty = User(uid: '0', name: 'Seleccione el Operador...', email: '');
    List<User> operators = _blocInvoice.buildOperators(snapshot.data.documents);
    operators.add(userSelectionEmpty);
    if (_selectedOperator != null && _selectedOperator.name.isEmpty) {
      _selectedOperator = userSelectionEmpty;
    }
    _dropdownMenuItems = _builtDropdownMenuItems(operators);
    return DropdownButton(
      isExpanded: true,
      items: _dropdownMenuItems,
      value: _selectedOperator,
      onChanged: onChangeDropDawn,
      hint: Text(
        "Seleccione el Operador...",
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


  ///Functions

  onChangeDropDawn(User selectedOperator) {
    setState(() {
      if (selectedOperator.uid == '0') {
        widget.selectOperator(User());
      } else {
        widget.selectOperator(selectedOperator);
      }
      _selectedOperator = selectedOperator;
    });
  }

  List<DropdownMenuItem<User>> _builtDropdownMenuItems(List users) {
    List<DropdownMenuItem<User>> listItems = List();
    for (User documentLoc in users) {
      listItems.add(
        DropdownMenuItem(
          value: documentLoc,
          child: Text(
            documentLoc.name,
          ),
        ),
      );
    }
    return listItems;
  }

  Future<Null> _datePickerFrom() async {
    final DateTime picked = await showDatePicker(context: context,
        initialDate: _dateTimeInit,
        firstDate: DateTime(1970),
        lastDate: DateTime(2100),
    );

    if (picked != null && picked != _dateTimeInit) {
      setState(() {
        _dateTimeInit = picked;
        _textDateInit.text = formatter.format(_dateTimeInit);
        widget.selectDateInit(_dateTimeInit);
      });
    }
  }

  Future<Null> _datePickerFinal() async {
    final DateTime picked = await showDatePicker(context: context,
      initialDate: _dateTimeFinal,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _dateTimeFinal) {
      setState(() {
        _dateTimeFinal = picked;
        _textDateFinal.text = formatter.format(_dateTimeFinal);
        widget.selectDateFinal(_dateTimeFinal);
      });
    }
  }

}
