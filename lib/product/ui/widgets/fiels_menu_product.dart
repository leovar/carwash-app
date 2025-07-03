import 'package:car_wash_app/vehicle_type/model/vehicleType.dart';
import 'package:flutter/material.dart';
import '../../../vehicle_type/bloc/vehicle_type_bloc.dart';
import '../../../widgets/popup_menu_widget.dart';

class FieldsMenuProduct extends StatefulWidget {
  final int listCountVehicleTypes;
  final Function(String, int, int, List<VehicleType>?) cbHandlerVehicleType;
  final selectedVehicleType;

  FieldsMenuProduct({
    Key? key,
    required this.listCountVehicleTypes,
    required this.cbHandlerVehicleType,
    required this.selectedVehicleType,
  });

  @override
  State<StatefulWidget> createState() {
    return _FieldsMenuProduct();
  }
}

class _FieldsMenuProduct extends State<FieldsMenuProduct> {
  VehicleTypeBloc _vehicleTypeBloc = VehicleTypeBloc();
  late List<VehicleType> _listVehicleTypes;
  List<String> _listVehicleTypesNames = <String>[];
  String _selectVehicleType = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectVehicleType = widget.selectedVehicleType;
    });
  }

  @override
  void didUpdateWidget(covariant FieldsMenuProduct oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selectVehicleType = widget.selectedVehicleType;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _getVehicleTypes(),
        SizedBox(height: 12),
      ]
    );
  }

  Widget _getVehicleTypes() {
    if (widget.listCountVehicleTypes == 0) {
      return StreamBuilder(
        stream: _vehicleTypeBloc.vehicleTypeStream,
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
    _listVehicleTypes = _vehicleTypeBloc.buildVehicleType(snapshot.data.docs);
    _listVehicleTypesNames = _listVehicleTypes.map((SysUser) => SysUser.vehicleType).toList();
    widget.cbHandlerVehicleType('', _listVehicleTypes.length, 2, _listVehicleTypes);
    return chargeCoordinatorsWidget();
  }

  Widget chargeCoordinatorsWidget() {
    return PopUpMenuWidget(
      popUpName: 'Tipo de vehículo',
      selectValue: _cbSelectValueVehicleType,
      listString: _listVehicleTypesNames,
      valueSelect: _selectVehicleType,
      enableForm: true,
      editForm: true,
    );
  }

  void _cbSelectValueVehicleType(String valueSelect) {
    _selectVehicleType = valueSelect;
    widget.cbHandlerVehicleType(valueSelect, 0, 1, null);
  }
}