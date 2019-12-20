import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/widgets/popup_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class FieldsMenusInvoice extends StatefulWidget {
  final int listCountOperators;
  final int listCountCoordinators;
  final int listCountBrands;
  final int listCountColors;
  final Function(String, int, int) cbHandlerOperator;
  final Function(String, int, int) cbHandlerCoordinator;
  final Function(String, int, int) cbHandlerVehicleBrand;
  final Function(String, int, int) cbHandlerVehicleColor;
  final selectedOperator;
  final selectedCoordinator;
  final locationReference;
  final String selectedVehicleBrand;
  final String selectedVehicleColor;
  final int uidVehicleType;
  final bool enableForm;
  final bool editOperator;

  FieldsMenusInvoice({
    Key key,
    this.listCountOperators,
    this.listCountCoordinators,
    this.listCountBrands,
    this.listCountColors,
    this.cbHandlerOperator,
    this.cbHandlerCoordinator,
    this.cbHandlerVehicleBrand,
    this.cbHandlerVehicleColor,
    this.selectedOperator,
    this.selectedCoordinator,
    this.locationReference,
    this.selectedVehicleBrand,
    this.selectedVehicleColor,
    this.uidVehicleType,
    this.enableForm,
    this.editOperator,
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
  List<String> _listBrands = <String>[];
  List<String> _listColors = <String>[];
  int _vehicleType = 0;
  String _selectedBrand = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedBrand = widget.selectedVehicleBrand;
    });
  }

  @override
  Widget build(BuildContext context) {
    _blocInvoice = BlocProvider.of(context);
    return Column(
      children: <Widget>[
        _getBrandsStream(),
        SizedBox(height: 9),
        _getColorsStream(),
        SizedBox(height: 9),
        _getOperators(),
        SizedBox(height: 9),
        _getCoordinators(),
      ],
    );
  }

  Widget _getOperators() {
    //El contador inicial arranca en 0, al consultra los usuarios operadores por primera vez
    // ya queda cargado con la cantidad de usuarios encontrados y no tiene que volver a hacer la consulta
    // cada vez que hace un set state.
    if (widget.listCountOperators == 0) {
      return StreamBuilder(
        stream: _blocInvoice.operatorsStream(),
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
      return chargeOperatorsControl();
    }
  }

  Widget showPopUpOperators(AsyncSnapshot snapshot) {
    _listUsersOperators = _blocInvoice.buildOperators(snapshot.data.documents);
    _listOperators = _listUsersOperators.map((user) => user.name).toList();
    widget.cbHandlerOperator('',_listUsersOperators.length, 2);
    return chargeOperatorsControl();
  }

  Widget chargeOperatorsControl() {
    return PopUpMenuWidget(
      popUpName: 'Operador',
      selectValue: _cbSelectValueOperator,
      listString: _listOperators,
      valueSelect: widget.selectedOperator,
      enableForm: (widget.editOperator || widget.enableForm)? true : false,
    );
  }

  Widget _getCoordinators() {
    if (widget.listCountCoordinators == 0) {
      return StreamBuilder(
        stream: _blocInvoice.coordinatorsStream(),
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
    widget.cbHandlerCoordinator('', _listUsersCoordinators.length, 2);
    return chargeCoordinatorsWidget();
  }

  Widget chargeCoordinatorsWidget() {
    return PopUpMenuWidget(
      popUpName: 'Coordinador',
      selectValue: _cbSelectValueCoordinator,
      listString: _listCoordinators,
      valueSelect: widget.selectedCoordinator,
      enableForm: widget.enableForm,
    );
  }

  Widget _getBrandsStream() {
    if (widget.listCountBrands == 0 || _vehicleType != widget.uidVehicleType) {
      //si estoy cambiando de tipo de vehiculo y no estoy en modo edición de factura, limpia el campo marca
      if (_vehicleType != widget.uidVehicleType && widget.enableForm) {
        _cbSelectValueBrands('');
      }

      int uidType;
      if (widget.uidVehicleType == 2) {
        uidType = 1;
      } else {
        uidType = widget.uidVehicleType;
      }
      _vehicleType = widget.uidVehicleType;

      return StreamBuilder(
        stream: _blocInvoice.brandsStream(uidType),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              return _getListBrands(snapshot);
          }
        },
      );
    } else {
      return _chargeListBrands();
    }
  }

  Widget _getListBrands(AsyncSnapshot snapshot) {
    _listBrands = _blocInvoice.buildBrands(snapshot.data.documents);
    widget.cbHandlerVehicleBrand('', _listBrands.length, 2);
    return _chargeListBrands();
  }

  Widget _chargeListBrands() {
    return PopUpMenuWidget(
      popUpName: 'Marca',
      selectValue: _cbSelectValueBrands,
      listString: _listBrands,
      valueSelect: _selectedBrand,
      enableForm: widget.enableForm,
    );
  }

  Widget _getColorsStream() {
    if (widget.listCountColors == 0) {
      int uidType;
      if (widget.uidVehicleType == 2) {
        uidType = 1;
      } else {
        uidType = widget.uidVehicleType;
      }

      return StreamBuilder(
        stream: _blocInvoice.colorsStream(uidType),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              return _getColorsList(snapshot);
          }
        },
      );
    } else {
      return _chargeListColors();
    }
  }

  Widget _getColorsList(AsyncSnapshot snapshot) {
    _listColors = _blocInvoice.buildColors(snapshot.data.documents);
    widget.cbHandlerVehicleColor('', _listColors.length, 2);
    return _chargeListColors();
  }

  Widget _chargeListColors() {
    return PopUpMenuWidget(
      popUpName: 'Color',
      selectValue: _cbSelectValueColor,
      listString: _listColors,
      valueSelect: widget.selectedVehicleColor,
      enableForm: widget.enableForm,
    );
  }

  /// Functions

  void _cbSelectValueOperator(String valueSelect) {
    widget.cbHandlerOperator(valueSelect, 0, 1);
  }

  void _cbSelectValueCoordinator(String valueSelect) {
    widget.cbHandlerCoordinator(valueSelect, 0, 1);
  }

  void _cbSelectValueBrands(String valueSelect) {
    _selectedBrand = valueSelect;
    widget.cbHandlerVehicleBrand(valueSelect, 0, 1);
  }

  void _cbSelectValueColor(String valueSelect) {
    widget.cbHandlerVehicleColor(valueSelect, 0, 1);
  }
}
