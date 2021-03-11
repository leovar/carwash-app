import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/widgets/popup_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class FieldsMenusInvoice extends StatefulWidget {
  final int listCountOperators;
  final int listCountCoordinators;
  final int listCountBrands;
  final int listCountBrandReference;
  final int listCountColors;
  final Function(String, int, int) cbHandlerOperator;
  final Function(String, int, int) cbHandlerCoordinator;
  final Function(String, int, int) cbHandlerVehicleBrand;
  final Function(String, int, int) cbHandlerVehicleBrandReference;
  final Function(String, int, int) cbHandlerVehicleColor;
  final Function(String, int, int) cbHandlerTypeSex;
  final selectedOperator;
  final selectedCoordinator;
  final String idLocation;
  final String selectedVehicleBrand;
  final String selectVehicleBrandReference;
  final String selectedVehicleColor;
  final String selectedTypeSex;
  final int uidVehicleType;
  final bool enableForm;
  final bool editOperator;

  FieldsMenusInvoice({
    Key key,
    this.listCountOperators,
    this.listCountCoordinators,
    this.listCountBrands,
    this.listCountBrandReference,
    this.listCountColors,
    this.cbHandlerOperator,
    this.cbHandlerCoordinator,
    this.cbHandlerVehicleBrand,
    this.cbHandlerVehicleBrandReference,
    this.cbHandlerVehicleColor,
    this.cbHandlerTypeSex,
    this.selectedOperator,
    this.selectedCoordinator,
    this.idLocation,
    this.selectedVehicleBrand,
    this.selectVehicleBrandReference,
    this.selectedVehicleColor,
    this.selectedTypeSex,
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
  List<String> _listBrandReferences = <String>[];
  List<String> _listColors = <String>[];
  List<String> _listTypeSex = <String>[];
  int _vehicleType = 0;
  String _selectTypeSex = '';
  String _selectOperator = '';
  String _selectCoordinator = '';
  String _selectedBrand = '';
  String _selectBrandReference = '';
  String _selectedColor = '';

  @override
  void initState() {
    super.initState();
    if (_listTypeSex.length <= 0) {
      _listTypeSex.add('Masculino');
      _listTypeSex.add('Femenino');
    }
    setState(() {
      _selectedBrand = widget.selectedVehicleBrand;
      _selectedColor = widget.selectedVehicleColor;
      _selectOperator = widget.selectedOperator;
      _selectCoordinator = widget.selectedCoordinator;
      _selectTypeSex = widget.selectedTypeSex;
      _selectBrandReference = widget.selectVehicleBrandReference;
    });
  }

  @override
  void didUpdateWidget(FieldsMenusInvoice oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selectedBrand = widget.selectedVehicleBrand;
    _selectBrandReference = widget.selectVehicleBrandReference;
    _selectedColor = widget.selectedVehicleColor;
    _selectTypeSex = widget.selectedTypeSex;
    _getListBrandReferences(_selectedBrand, updateRef: _selectBrandReference);
    _getAllListBrands(_selectedBrand);
  }

  @override
  Widget build(BuildContext context) {
    //_selectedBrand = widget.editFromInvoiceForm ? widget.selectedVehicleBrand : _selectedBrand;
    _blocInvoice = BlocProvider.of(context);
    return Column(
      children: <Widget>[
        _chargeListTypeSex(),
        SizedBox(height: 9),
        _chargeListBrands(), //_getBrandsStream(),  //se comenta por que se carga todas las referencias
        SizedBox(height: 9),
        _chargeListBrandReferences(),
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
        stream: _blocInvoice.operatorsByLocationStream(widget.idLocation),
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
    widget.cbHandlerOperator('', _listUsersOperators.length, 2);
    return chargeOperatorsControl();
  }

  Widget chargeOperatorsControl() {
    return PopUpMenuWidget(
      popUpName: 'Operador',
      selectValue: _cbSelectValueOperator,
      listString: _listOperators,
      valueSelect: _selectOperator,
      enableForm: (widget.editOperator || widget.enableForm) ? true : false,
    );
  }

  Widget _getCoordinators() {
    if (widget.listCountCoordinators == 0) {
      return StreamBuilder(
        stream: _blocInvoice.coordinatorsByLocationStream(widget.idLocation),
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
      valueSelect: _selectCoordinator,
      enableForm: widget.enableForm,
    );
  }

  // List Brands
  Widget _getBrandsStream() {
    //si estoy cambiando de tipo de vehiculo y no estoy en modo edición de factura, cambia la marca segun el tipo de vehiculo
    //Borro la marca que estaba seleccionada si se cambia el tipo de vehiculo
    if (_vehicleType != widget.uidVehicleType && widget.enableForm) {
      _cbSelectValueBrands('');
    }

    // if vehicle type is 4x4 trucks(2) select the same vehicle type (1), to charge the same brands
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
  }

  Widget _getListBrands(AsyncSnapshot snapshot) {
    _listBrands = _blocInvoice.buildBrandsInvoice(snapshot.data.documents);
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

  // List Brand References
  Widget _chargeListBrandReferences() {
    return PopUpMenuWidget(
      popUpName: 'Referencia',
      selectValue: _cbSelectValueBrandReference,
      listString: _listBrandReferences,
      valueSelect: _selectBrandReference ?? 'Referencia',
      enableForm: widget.enableForm,
    );
  }

  // List Colors
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
      valueSelect: _selectedColor,
      enableForm: widget.enableForm,
    );
  }

  Widget _chargeListTypeSex() {
    return PopUpMenuWidget(
      popUpName: 'Sexo',
      selectValue: _cbSelectTypeSex,
      listString: _listTypeSex,
      valueSelect: _selectTypeSex ?? 'Sexo',
      enableForm: widget.enableForm,
    );
  }

  /// Functions

  void _cbSelectValueOperator(String valueSelect) {
    _selectOperator = valueSelect;
    widget.cbHandlerOperator(valueSelect, 0, 1);
  }

  void _cbSelectValueCoordinator(String valueSelect) {
    _selectCoordinator = valueSelect;
    widget.cbHandlerCoordinator(valueSelect, 0, 1);
  }

  void _cbSelectValueBrands(String valueSelect) {
    _getListBrandReferences(valueSelect);
    widget.cbHandlerVehicleBrand(valueSelect, 0, 1);
    _selectedBrand = valueSelect;
  }

  void _cbSelectValueBrandReference(String valueSelect) {
    _selectBrandReference = valueSelect;
    widget.cbHandlerVehicleBrandReference(valueSelect, 0, 1);
  }

  void _cbSelectValueColor(String valueSelect) {
    _selectedColor = valueSelect;
    widget.cbHandlerVehicleColor(valueSelect, 0, 1);
  }

  void _cbSelectTypeSex(String valueSelected) {
    _selectTypeSex = valueSelected;
    widget.cbHandlerTypeSex(valueSelected, 0, 1);
  }

  void _getListBrandReferences(String brandSelected, {String updateRef = ''}) {
    _blocInvoice.getBrandReferences(brandSelected).then((result) {
      widget.cbHandlerVehicleBrandReference('', result.length, 2);
      setState(() {
        _listBrandReferences = result;
        _selectBrandReference = '';
        if (updateRef.isNotEmpty) {
          _selectBrandReference = updateRef;
        }
      });
    });
  }

  void _getAllListBrands(String brandSelected) {
    _blocInvoice.getAllBrandsInvoice().then((result) {
      widget.cbHandlerVehicleBrand('', result.length, 2);
      setState(() {
        _listBrands = result;
      });
    });
  }
}
