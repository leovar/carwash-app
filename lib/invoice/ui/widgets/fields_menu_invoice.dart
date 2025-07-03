import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/payment_methods/bloc/bloc_payment_method.dart';
import 'package:car_wash_app/payment_methods/model/payment_methods.dart';
import 'package:car_wash_app/user/model/sysUser.dart';
import 'package:car_wash_app/widgets/popup_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class FieldsMenusInvoice extends StatefulWidget {
  final int listCountCoordinators;
  final int listCountBrands;
  final int listCountBrandReference;
  final int listCountColors;
  final int listCountPaymentMethods;
  final Function(String, int, int) cbHandlerCoordinator;
  final Function(String, int, int) cbHandlerVehicleBrand;
  final Function(String, int, int) cbHandlerVehicleBrandReference;
  final Function(String, int, int) cbHandlerVehicleColor;
  final Function(String, int, int) cbHandlerTypeSex;
  final Function(String, int, int) cbHandlerPaymentMethod;
  final selectedCoordinator;
  final String idLocation;
  final String selectedVehicleBrand;
  final String selectVehicleBrandReference;
  final String selectedVehicleColor;
  final String selectedTypeSex;
  final String selectedPaymentMethod;
  final int uidVehicleType;
  final bool enableForm;

  FieldsMenusInvoice({
    Key? key,
    required this.listCountCoordinators,
    required this.listCountBrands,
    required this.listCountBrandReference,
    required this.listCountColors,
    required this.listCountPaymentMethods,
    required this.cbHandlerCoordinator,
    required this.cbHandlerVehicleBrand,
    required this.cbHandlerVehicleBrandReference,
    required this.cbHandlerVehicleColor,
    required this.cbHandlerTypeSex,
    required this.cbHandlerPaymentMethod,
    required this.selectedCoordinator,
    required this.idLocation,
    required this.selectedVehicleBrand,
    required this.selectVehicleBrandReference,
    required this.selectedVehicleColor,
    required this.selectedTypeSex,
    required this.selectedPaymentMethod,
    required this.uidVehicleType,
    required this.enableForm,
  });

  @override
  State<StatefulWidget> createState() {
    return _FieldsMenusInvoice();
  }
}

class _FieldsMenusInvoice extends State<FieldsMenusInvoice> {
  late BlocInvoice _blocInvoice;
  BlocPaymentMethod _paymentMethodBloc = BlocPaymentMethod();
  late List<SysUser> _listUsersCoordinators;
  late List<PaymentMethod> _listMasterPaymentsMethods;
  List<String> _listCoordinators = <String>[];
  List<String> _listBrands = <String>[];
  List<String> _listBrandReferences = <String>[];
  List<String> _listColors = <String>[];
  List<String> _listTypeSex = <String>[];
  List<String> _listPaymentMethods = <String>[];
  int _vehicleType = 0;
  String _selectTypeSex = '';
  String _selectCoordinator = '';
  String _selectedBrand = '';
  String _selectBrandReference = '';
  String _selectedColor = '';
  String _selectPaymentMethod = '';

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
      _selectCoordinator = widget.selectedCoordinator;
      _selectTypeSex = widget.selectedTypeSex;
      _selectPaymentMethod = widget.selectedPaymentMethod;
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
    _selectPaymentMethod = widget.selectedPaymentMethod;
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
        SizedBox(height: 12),
        _chargeListBrands(), //_getBrandsStream(),  //se comenta por que se carga todas las referencias
        SizedBox(height: 12),
        _chargeListBrandReferences(),
        SizedBox(height: 12),
        _getColorsStream(),
        SizedBox(height: 12),
        _getCoordinators(),
        SizedBox(height: 12),
        _getPaymentMethods(),
      ],
    );
  }

  Widget _getCoordinators() {
    if (widget.listCountCoordinators == 0) {
      if (widget.idLocation == '') {
        return CircularProgressIndicator();
      }

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
    _listUsersCoordinators = _blocInvoice.buildCoordinators(snapshot.data.docs);
    _listCoordinators = _listUsersCoordinators.map((SysUser) => SysUser.name).toList();
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
      editForm: false,
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
    _listBrands = _blocInvoice.buildBrandsInvoice(snapshot.data.docs);
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
      editForm: false,
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
      editForm: false,
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
    _listColors = _blocInvoice.buildColors(snapshot.data.docs);
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
      editForm: false,
    );
  }

  Widget _chargeListTypeSex() {
    return PopUpMenuWidget(
      popUpName: 'Sexo',
      selectValue: _cbSelectTypeSex,
      listString: _listTypeSex,
      valueSelect: _selectTypeSex ?? 'Sexo',
      enableForm: widget.enableForm,
      editForm: false,
    );
  }

  Widget _getPaymentMethods() {
    if (widget.listCountPaymentMethods == 0) {
      return StreamBuilder(
        stream: _paymentMethodBloc.paymentMethodsStream(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              return showPopUpPaymentMethods(snapshot);
          }
        },
      );
    } else {
      return chargePaymentMethodsControl();
    }
  }

  Widget showPopUpPaymentMethods(AsyncSnapshot snapshot) {
    _listMasterPaymentsMethods = _paymentMethodBloc.buildPaymentMethods(snapshot.data.docs);
    _listPaymentMethods = _listMasterPaymentsMethods.map((pm) => pm.name).toList().whereType<String>().toList();
    widget.cbHandlerPaymentMethod('', _listMasterPaymentsMethods.length, 2);
    return chargePaymentMethodsControl();
  }

  Widget chargePaymentMethodsControl() {
    return PopUpMenuWidget(
      popUpName: 'Método de pago',
      selectValue: _cbSelectPaymentMethod,
      listString: _listPaymentMethods,
      valueSelect: _selectPaymentMethod??'',
      enableForm: widget.enableForm,
      editForm: false,
    );
  }

  /// Functions

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

  void _cbSelectPaymentMethod(String valueSelected) {
    _selectPaymentMethod = valueSelected;
    widget.cbHandlerPaymentMethod(valueSelected, 0, 1);
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
