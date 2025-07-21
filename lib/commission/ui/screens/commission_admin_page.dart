import 'package:car_wash_app/commission/bloc/bloc_commission.dart';
import 'package:car_wash_app/commission/model/commission.dart';
import 'package:car_wash_app/invoice/ui/widgets/text_field_input.dart';
import 'package:car_wash_app/vehicle_type/bloc/vehicle_type_bloc.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class CommissionAdminPage extends StatefulWidget {
  final Commission currentCommission;
  final String iconVehicle;
  final String vehicleType;
  final String companyId;

  CommissionAdminPage(
      {Key? key, required this.currentCommission, required this.iconVehicle, required this.vehicleType, required this.companyId});

  @override
  State<StatefulWidget> createState() => _CommissionAdminPage();
}

class _CommissionAdminPage extends State<CommissionAdminPage> {
  late BlocCommission _blocCommission;
  VehicleTypeBloc _vehicleTypeBloc = VehicleTypeBloc();
  late Commission _commissionSelected;

  bool _validateValue = false;
  bool _isPercentage = false;
  bool _isValue = false;
  bool _isCalculatedPerCount = false;
  final _productType = TextEditingController();
  final _value = TextEditingController();
  final _valueCommissionThreshold = TextEditingController();
  final _valueBeforeThreshold = TextEditingController();

  @override
  void initState() {
    super.initState();
    _commissionSelected = widget.currentCommission;
    _selectCommissionList();
    }

  @override
  Widget build(BuildContext context) {
    _blocCommission = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Comisión",
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
      body: SafeArea(
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          child: _containerBody(),
        ),
      ),
    );
  }

  Widget _containerBody() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 17, horizontal: 16),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 9),
            Container(
              height: 50,
              child: Image.asset(widget.iconVehicle, width: 56),
            ),
            Text(
              widget.vehicleType,
              style: TextStyle(
                fontFamily: "Lato",
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Color(0xFF59B258),
              ),
            ),
            SizedBox(height: 20),
            Container(
              child: TextFieldInput(
                labelText: 'Tipo de producto',
                textController: _productType,
                enable: false,
                inputType: TextInputType.multiline,
              ),
            ),
            SizedBox(height: 18),
            Container(
              child: TextFieldInput(
                labelText: 'Valor de comisión',
                textController: _value,
                validate: _validateValue,
                textValidate: 'Escriba el valor de comisión',
                inputType: TextInputType.number,
                textInputFormatter: [
                  FilteringTextInputFormatter.allow(RegExp("^[0-9.]*")),
                ],
              ),
            ),
            SizedBox(height: 18),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: TextFieldInput(
                    labelText: 'Umbral de precio para comisión',
                    textController: _valueCommissionThreshold,
                    validate: _validateValue,
                    textValidate:
                        'Escriba el valor del umbral de precio si aplica',
                    inputType: TextInputType.number,
                    textInputFormatter: [
                      FilteringTextInputFormatter.allow(RegExp("^[0-9.]*")),
                    ],
                  ),
                ),
                Text(
                  'Escriba el valor de umbral si aplica de lo contrario coloque 0',
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            SizedBox(height: 18),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  child: TextFieldInput(
                    labelText: 'Valor de comisión debajo del umbral',
                    textController: _valueBeforeThreshold,
                    validate: _validateValue,
                    textValidate: 'Escriba el valor de comisión',
                    inputType: TextInputType.number,
                    textInputFormatter: [
                      FilteringTextInputFormatter.allow(RegExp("^[0-9.]*")),
                    ],
                  ),
                ),
                Flexible(
                  child: Text(
                    'Escriba el valor de comisión que aplica por debajo del umbral de lo contrario coloque 0',
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 18),
            Flexible(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _isPercentage,
                    onChanged: (bool? value) {
                      _onChangeValueType(1, value);
                    },
                    checkColor: Colors.white,
                    activeColor: Color(0xFF59B258),
                  ),
                  Text(
                    "Calcular por porcentaje",
                    style: TextStyle(
                      fontFamily: "Lato",
                      decoration: TextDecoration.none,
                      color: Color(0xFFAEAEAE),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18),
            Flexible(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _isValue,
                    onChanged: (bool? value) {
                      _onChangeValueType(2, value);
                    },
                    checkColor: Colors.white,
                    activeColor: Color(0xFF59B258),
                  ),
                  Text(
                    "Calcular por valor",
                    style: TextStyle(
                      fontFamily: "Lato",
                      decoration: TextDecoration.none,
                      color: Color(0xFFAEAEAE),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 18),
            Flexible(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _isCalculatedPerCount,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null) {
                          _isCalculatedPerCount = value;
                        }
                      });
                    },
                    checkColor: Colors.white,
                    activeColor: Color(0xFF59B258),
                  ),
                  Text(
                    "Es cálculo por conteo de servicios ?",
                    style: TextStyle(
                      fontFamily: "Lato",
                      decoration: TextDecoration.none,
                      color: Color(0xFFAEAEAE),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: _buttonSave(),
            ),
            SizedBox(height: 9),
          ],
        ),
      ),
    );
  }

  Widget _buttonSave() {
    return Container(
      height: 100,
      child: Align(
        alignment: Alignment.center,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
            backgroundColor: Color(0xFF59B258),
          ),
          child: Text(
            "Guardar",
            style: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 19,
            ),
          ),
          onPressed: () {
            _saveProduct();
          },
        ),
      ),
    );
  }

  void _selectCommissionList() {
    _value.text = _commissionSelected.value?.toStringAsFixed(2)??'';
    _productType.text = _commissionSelected.productType??'';
    _isPercentage = _commissionSelected.isPercentage??false;
    _isValue = _commissionSelected.isValue??false;
    _isCalculatedPerCount = _commissionSelected.calculatePerCount??false;
    _valueCommissionThreshold.text = _commissionSelected.commissionThreshold?.toStringAsFixed(2)??'0';
    _valueBeforeThreshold.text = _commissionSelected.valueBeforeThreshold?.toStringAsFixed(2)??'0';
  }

  //1. por porcentaje, 2. por valor
  void _onChangeValueType(int productType, bool? value) {
    setState(() {
      switch (productType) {
        case 1:
          _isPercentage = value??false;
          _isValue = false;
          break;
        case 2:
          _isPercentage = false;
          _isValue = value??false;
          break;
      }
    });
  }

  void _saveProduct() async {
    if (_validateInputs()) {
      MessagesUtils.showAlertWithLoading(context: context, title: 'Guardando')
          .show();

      final commission = Commission(
        id: _commissionSelected.id,
        isPercentage: _isPercentage,
        isValue: _isValue,
        productType: _commissionSelected.productType,
        uidVehicleType: _commissionSelected.uidVehicleType,
        value: double.tryParse(_value.text.trim()) ?? 0.0,
        calculatePerCount: _isCalculatedPerCount,
        commissionThreshold: double.tryParse(_valueCommissionThreshold.text.trim()) ?? 0,
        valueBeforeThreshold: double.tryParse(_valueBeforeThreshold.text.trim()) ?? 0,
        companyId: widget.companyId,
      );

      _blocCommission.updateCommission(commission);

      Navigator.pop(context);
      Navigator.pop(context);

      _clearData();
    }
  }

  bool _validateInputs() {
    bool canSave = true;
    if (_value.text.isEmpty) {
      _validateValue = true;
      canSave = false;
    } else
      _validateValue = false;

    if (!_isPercentage && !_isValue) {
      canSave = false;
    }

    return canSave;
  }

  void _clearData() {
    _value.text = '';
  }
}
