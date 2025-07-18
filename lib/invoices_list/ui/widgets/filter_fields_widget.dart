import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/payment_methods/bloc/bloc_payment_method.dart';
import 'package:car_wash_app/payment_methods/model/payment_methods.dart';
import 'package:car_wash_app/user/model/sysUser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class FilterFieldsWidget extends StatefulWidget {
  final TextEditingController placaController;
  final TextEditingController consecutiveController;
  final DateTime dateInit;
  final DateTime dateFinal;
  final SysUser operatorSelected;
  final String productTypeSelected;
  final PaymentMethod paymentMethodSelected;
  final Function(SysUser) selectOperator;
  final Function(DateTime) selectDateInit;
  final Function(DateTime) selectDateFinal;
  final Function(String) selectProductType;
  final Function(PaymentMethod) selectPaymentMethod;

  FilterFieldsWidget({
    Key? key,
    required this.placaController,
    required this.consecutiveController,
    required this.dateInit,
    required this.dateFinal,
    required this.operatorSelected,
    required this.productTypeSelected,
    required this.paymentMethodSelected,
    required this.selectOperator,
    required this.selectDateInit,
    required this.selectDateFinal,
    required this.selectProductType,
    required this.selectPaymentMethod,
  });

  @override
  State<StatefulWidget> createState() => _FilterFieldsWidget();
}

class _FilterFieldsWidget extends State<FilterFieldsWidget> {
  BlocInvoice _blocInvoice = BlocInvoice();
  BlocPaymentMethod _paymentMethodBloc = BlocPaymentMethod();
  final _textDateInit = TextEditingController();
  final _textDateFinal = TextEditingController();
  late List<DropdownMenuItem<SysUser>> _dropdownMenuItems;
  late List<DropdownMenuItem<PaymentMethod>> _dropdownMenuItemsPayments;
  late List<DropdownMenuItem<String>> _dropdownMenuItemsProductTypes;
  List<String> _productsTypeList = [];
  SysUser _selectedOperator = new SysUser(uid: '', name: '', email: '');
  late DateTime _dateTimeInit;
  late DateTime _dateTimeFinal;
  late String _selectProductType;
  late PaymentMethod _selectedPaymentMethod;
  var formatter = new DateFormat('dd-MM-yyyy');
  var _emptySelectionProductType = 'Typo de Servicio..';

  @override
  void initState() {
    super.initState();
    _productsTypeList.add('Sencillo');
    _productsTypeList.add('Especial');
    _productsTypeList.add(_emptySelectionProductType);
    _dateTimeInit = widget.dateInit;
    _dateTimeFinal = widget.dateFinal;
    _textDateInit.text = formatter.format(_dateTimeInit);
    _textDateFinal.text = formatter.format(_dateTimeFinal);
    _selectProductType = widget.productTypeSelected;
    _selectedPaymentMethod = widget.paymentMethodSelected;
    if (widget.operatorSelected.id != null) {
      _selectedOperator = widget.operatorSelected;
    }
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
            FilteringTextInputFormatter.allow(RegExp("^[a-zA-Z0-9]*")),
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
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp('[0-9]'))],
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 10),
        _selectProductTypeControl(),
        SizedBox(height: 10),
        _getPaymentMethods(),
      ],
    );
  }

  Widget _selectDateInit() {
    return TextField(
      controller: _textDateInit,
      decoration: InputDecoration(labelText: 'Fecha Desde'),
      keyboardType: TextInputType.datetime,
      readOnly: true,
      onTap: () {
        _datePickerFrom();
      },
    );
  }

  Widget _selectDateFinal() {
    return TextField(
      controller: _textDateFinal,
      decoration: InputDecoration(labelText: 'Fecha Hasta'),
      keyboardType: TextInputType.datetime,
      readOnly: true,
      onTap: () {
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
    List<SysUser> operators = _blocInvoice.buildOperators(snapshot.data.docs);
    operators.sort((a,b) => a.name.compareTo(b.name));

    _dropdownMenuItems = _builtDropdownMenuItems(operators);
    return DropdownButton(
      isExpanded: true,
      items: _dropdownMenuItems,
      value: _selectedOperator,
      onChanged: onChangeDropDawn,
      hint: Text("Seleccione el Operador..."),
      icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).cardColor),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(
        fontFamily: "AvenirNext",
        fontWeight: FontWeight.normal,
        color: Theme.of(context).cardColor,
      ),
      underline: Container(height: 1, color: Theme.of(context).textSelectionTheme.cursorColor),
    );
  }

  Widget _getPaymentMethods() {
    return StreamBuilder(
      stream: _paymentMethodBloc.paymentMethodsStream(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return _showPaymentMethods(snapshot);
        }
      },
    );
  }

  Widget _showPaymentMethods(AsyncSnapshot snapshot) {
    var paymentMethodSelectionEmpty = PaymentMethod(
      id: '0',
      name: 'Seleccione el método de pago...',
      active: true,
    );
    List<PaymentMethod> paymentMethods = _paymentMethodBloc.buildPaymentMethods(
      snapshot.data.docs,
    );
    paymentMethods.add(paymentMethodSelectionEmpty);
    if (_selectedPaymentMethod.name!.isEmpty) {
      _selectedPaymentMethod = paymentMethodSelectionEmpty;
    }
    _dropdownMenuItemsPayments = _builtDropdownMenuItemsPaymentMethods(
      paymentMethods,
    );
    return DropdownButton(
      isExpanded: true,
      items: _dropdownMenuItemsPayments,
      value: _selectedPaymentMethod,
      onChanged: onChangeDropDawnPaymentMethods,
      hint: Text("Seleccione el método de pago..."),
      icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).cardColor),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(
        fontFamily: "AvenirNext",
        fontWeight: FontWeight.normal,
        color: Theme.of(context).cardColor,
      ),
      underline: Container(height: 1, color: Theme.of(context).textSelectionTheme.cursorColor),
    );
  }

  Widget _selectProductTypeControl() {
    if (_selectProductType.isEmpty) {
      _selectProductType = _emptySelectionProductType;
    }
    _dropdownMenuItemsProductTypes = _builtDropdownProductTypes();
    return DropdownButton(
      isExpanded: true,
      items: _dropdownMenuItemsProductTypes,
      value: _selectProductType,
      onChanged: onChangeDropDawnProductTypes,
      hint: Text("Typo de Servicio.."),
      icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).cardColor),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(
        fontFamily: "AvenirNext",
        fontWeight: FontWeight.normal,
        color: Theme.of(context).cardColor,
      ),
      underline: Container(height: 1, color: Theme.of(context).textSelectionTheme.cursorColor),
    );
  }

  ///Functions

  onChangeDropDawn(SysUser? selectedOperator) {
    setState(() {
      if (selectedOperator != null) {
        if (selectedOperator.uid == '0') {
          widget.selectOperator(SysUser(name: '', uid: '', email: ''));
        } else {
          widget.selectOperator(selectedOperator);
        }
        _selectedOperator = selectedOperator;
      }
    });
  }

  List<DropdownMenuItem<SysUser>> _builtDropdownMenuItems(List users) {
    List<DropdownMenuItem<SysUser>> listItems = [];
    SysUser emptyUser = SysUser(uid: '', name: '', email: '');
    if (_selectedOperator.id == null) {
      listItems.add(
        DropdownMenuItem(
            value: _selectedOperator,
            child: Text('Seleccione el Operador...'),
        ),
      );
    } else {
      listItems.add(
        DropdownMenuItem(
          value: emptyUser,
          child: Text('Seleccione el Operador...'),
        ),
      );
    }
    for (SysUser documentLoc in users) {
      listItems.add(
        DropdownMenuItem(value: documentLoc, child: Text(documentLoc.name)),
      );
    }
    return listItems;
  }

  onChangeDropDawnPaymentMethods(PaymentMethod? selectedPaymentMethod) {
    setState(() {
      if (selectedPaymentMethod != null) {
        if (selectedPaymentMethod.id == '0') {
          widget.selectPaymentMethod(PaymentMethod(name: '', id: ''));
        } else {
          widget.selectPaymentMethod(selectedPaymentMethod);
        }
        _selectedPaymentMethod = selectedPaymentMethod;
      }
    });
  }

  List<DropdownMenuItem<PaymentMethod>> _builtDropdownMenuItemsPaymentMethods(
    List paymentMethods,
  ) {
    List<DropdownMenuItem<PaymentMethod>> listItems = [];
    for (PaymentMethod documentLoc in paymentMethods) {
      listItems.add(
        DropdownMenuItem(value: documentLoc, child: Text(documentLoc.name??'')),
      );
    }
    return listItems;
  }

  onChangeDropDawnProductTypes(String? selectedProductType) {
    setState(() {
      widget.selectProductType(selectedProductType??'');
      _selectProductType = selectedProductType??'';
    });
  }

  List<DropdownMenuItem<String>> _builtDropdownProductTypes() {
    List<DropdownMenuItem<String>> listItems = [];
    for (String documentLoc in _productsTypeList) {
      listItems.add(
        DropdownMenuItem(value: documentLoc, child: Text(documentLoc)),
      );
    }
    return listItems;
  }

  Future<Null> _datePickerFrom() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateTimeInit,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );

    if (picked != _dateTimeInit) {
      setState(() {
        if (picked != null) {
          _dateTimeInit = picked;
        }
        _textDateInit.text = formatter.format(_dateTimeInit);
        widget.selectDateInit(_dateTimeInit);
      });
    }
  }

  Future<Null> _datePickerFinal() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateTimeFinal,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );

    if (picked != _dateTimeFinal) {
      setState(() {
        if (picked != null) {
          _dateTimeFinal = picked;
        }
        _textDateFinal.text = formatter.format(_dateTimeFinal);
        widget.selectDateFinal(_dateTimeFinal);
      });
    }
  }
}
