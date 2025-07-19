
import 'package:car_wash_app/invoice/ui/widgets/text_field_input.dart';
import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/location/ui/screens/locations_select_list_page.dart';
import 'package:car_wash_app/product/bloc/product_bloc.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/vehicle_type/bloc/vehicle_type_bloc.dart';
import 'package:car_wash_app/vehicle_type/model/vehicleType.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

import '../../../widgets/popup_menu_widget.dart';
import '../widgets/fiels_menu_product.dart';

class ProductAdminPage extends StatefulWidget {

  final Product? currentProduct;
  final String companyId;

  ProductAdminPage({Key? key, required this.companyId, this.currentProduct});

  @override
  State<StatefulWidget> createState() => _ProductAdminPage();
}

class _ProductAdminPage extends State<ProductAdminPage> {
  late ProductBloc _productBloc;
  BlocLocation _blocLocation = BlocLocation();
  VehicleTypeBloc _vehicleTypeBloc = VehicleTypeBloc();

  bool _validateName = false;
  bool _validatePrice = false;
  final _textProductName = TextEditingController();
  final _textPrice = TextEditingController();
  final _textIvaPercent = TextEditingController();
  final _textServiceTime = TextEditingController();
  final double _heightTextField = 60;
  final String _initialIvaPercent = '19';
  List<Product> _productList = <Product>[];
  List<Location> _listLocation = <Location>[];
  List<VehicleType> _lisVehicleType = [];
  late List<DropdownMenuItem<VehicleType>> _dropdownVehicleTypes;
  VehicleType _selectedVehicleType = new VehicleType(vehicleType: '');
  String _selectedVehicleTypeString = '';
  bool _productActive = true;
  bool _productTypeSpecial = false;
  bool _productTypeSimple = false;
  late Product _productSelected;
  int _listVehicleTypesCount = 0;

  @override
  void initState() {
    super.initState();
    //_textIvaPercent.text = _initialIvaPercent;
    _productSelected = widget.currentProduct ?? new Product(locations: []);
    _selectProductList();
  }

  @override
  Widget build(BuildContext context) {
    _productBloc = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Servicios",
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
          children: <Widget>[
            SizedBox(height: 9),
            Flexible(
              child: Container(
                child: TextFieldInput(
                  labelText: 'Nombre del Sevicio',
                  textController: _textProductName,
                  validate: _validateName,
                  textValidate: 'Escriba el nombre del producto',
                  inputType: TextInputType.multiline,
                  maxLines: 10,
                ),
              ),
            ),
            SizedBox(height: 9),
            Container(
              height: _heightTextField,
              child: TextFieldInput(
                labelText: 'Valor',
                textController: _textPrice,
                validate: _validatePrice,
                autofocus: false,
                textValidate: 'Escriba el valor del producto',
                inputType: TextInputType.number,
                textInputFormatter: [
                  FilteringTextInputFormatter.allow(RegExp("^[0-9.]*")),
                ],
              ),
            ),
            SizedBox(height: 9),
            Container(
              height: _heightTextField,
              child: TextFieldInput(
                labelText: '% De Iva',
                textController: _textIvaPercent,
                textValidate: 'Escriba el % de iva del producto',
                inputType: TextInputType.number,
                textInputFormatter: [
                  FilteringTextInputFormatter.allow(RegExp("^[0-9.]*")),
                ],
              ),
            ),
            SizedBox(height: 9),
            Container(
              height: _heightTextField,
              child: TextFieldInput(
                labelText: 'Duración del servicio (minutos)',
                textController: _textServiceTime,
                textValidate: 'Escriba la duración del servicio en minutos',
                inputType: TextInputType.number,
                textInputFormatter: [
                  FilteringTextInputFormatter.allow(RegExp("^[0-9.]*")),
                ],
              ),
            ),
            SizedBox(height: 9),
            _locationsToSelect(),
            SizedBox(height: 9),
            Flexible(
              child: FieldsMenuProduct(
                listCountVehicleTypes: _listVehicleTypesCount,
                cbHandlerVehicleType: _setHandlerUserCoordinator,
                selectedVehicleType: _selectedVehicleTypeString,
              ),
            ),
            SizedBox(height: 9),
            Flexible(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _productTypeSpecial,
                    onChanged: (bool? value) {
                      _onChangeRol(1, value);
                    },
                    checkColor: Colors.white,
                    activeColor: Color(0xFF59B258),
                  ),
                  Text(
                    "Servicio Especial",
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
            SizedBox(height: 9),
            Flexible(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _productTypeSimple,
                    onChanged: (bool? value) {
                      _onChangeRol(2, value);
                    },
                    checkColor: Colors.white,
                    activeColor: Color(0xFF59B258),
                  ),
                  Text(
                    "Servicio Sencillo",
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
            SizedBox(height: 9),
            Flexible(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _productActive,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value != null) {
                          _productActive = value;
                        }
                      });
                    },
                    checkColor: Colors.white,
                    activeColor: Color(0xFF59B258),
                  ),
                  Text(
                    "Servicio Activo",
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
            SizedBox(height: 9),
            Flexible(
              child: _buttonSave(),
            ),
            SizedBox(height: 9),
          ],
        ),
      ),
    );
  }

  Widget _locationsToSelect() {
    return StreamBuilder(
      stream: _blocLocation.locationsListStream(widget.companyId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return _getLocationsToSelectWidget(snapshot);
        }
      },
    );
  }

  Widget _getLocationsToSelectWidget(AsyncSnapshot snapshot) {
    if (_blocLocation.buildLocations(snapshot.data.docs).length != _listLocation.length) {
      _listLocation = _blocLocation.buildLocations(snapshot.data.docs);
      _selectProductList();
    }
    return InkWell(
      child: Container(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                '${_listLocation.where((f) => (f.isSelected??false)).toList().length} sedes agregadas',
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  color: Color(0xFF59B258),
                  fontSize: 17,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  size: 30,
                ),
                onPressed: (){},
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          color: Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationsSelectListPage(
              callbackSetLocationsList: _setLocationsDb,
              locationsList: _listLocation,
            ),
          ),
        );
      },
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

  /// Functions

  ///Function product selected
  void _selectProductList() {
    _validateName = false;
    _validatePrice = false;
    _textProductName.text = _productSelected.productName??'';
    _textIvaPercent.text = (_productSelected.ivaPercent ?? 0).toStringAsFixed(0);
    _textPrice.text = (_productSelected.price ?? 0).toStringAsFixed(2);
    _textServiceTime.text = _productSelected.serviceTime == null ? '0' : (_productSelected.serviceTime ?? 0).toStringAsFixed(0);
    _productActive = _productSelected.productActive ?? true;
    _productTypeSimple = _productSelected.productType == 'Sencillo' ? true : false;
    _productTypeSpecial = _productSelected.productType == 'Especial' ? true : false;
    _selectedVehicleTypeString = '';
    _selectedVehicleType = new VehicleType(vehicleType: '');
    _getVehicleTypeByReference(_productSelected.vehicleType);
    _listLocation.forEach((Location loc) {
      List<DocumentReference> dr = [];
      if ((_productSelected.locations??[]).length > 0) {
        dr = (_productSelected.locations??[]).where((e) => e.id == loc.id).toList();
      }
      if (dr.length > 0) {
        _listLocation[_listLocation.indexOf(loc)].isSelected = true;
      } else {
        _listLocation[_listLocation.indexOf(loc)].isSelected = false;
      }
    });
  }

  Future<void> _getVehicleTypeByReference (DocumentReference? valueRef) async {
    if (valueRef != null) {
      DocumentSnapshot docSnapshot = await valueRef.get();
      if (docSnapshot.exists) {
        VehicleType vType = VehicleType.fromJson(docSnapshot.data() as Map<String, dynamic>, id: docSnapshot.id);
        if (_lisVehicleType.isNotEmpty && (vType.id??'') != '') {
          _selectedVehicleType = _lisVehicleType.firstWhere((f) => f.id == (vType.id??''));
          setState(() {
            _selectedVehicleTypeString = vType.vehicleType??'';
          });
        }
      }
    }
  }

  ///Functions Select Menu
  void _setHandlerUserCoordinator(String selectVehicleType, int countList, int operationType, List<VehicleType>? vehiclesList) {
    if (operationType == 1) {
      _selectedVehicleTypeString = selectVehicleType;
      _selectedVehicleType = _lisVehicleType.firstWhere((vType) => vType.vehicleType == selectVehicleType);
    } else {
      _listVehicleTypesCount = countList;
      _lisVehicleType = vehiclesList??[];
    }
  }

  ///Functions Locations
  void _setLocationsDb(List<Location> locationsListSelected) {
    setState(() {
      _listLocation = locationsListSelected;
    });
  }

  ///Functions VehicleType
  onChangeDropDawn(String? selectedVehicleType) {
    if (selectedVehicleType != null) {
      _selectedVehicleTypeString = selectedVehicleType;
      _selectedVehicleType = _lisVehicleType.firstWhere((vType) => vType.vehicleType == selectedVehicleType);
    }
  }

  unfocusTextFields() {
    FocusScope.of(context).unfocus();
  }

  bool _validateInputs() {
    bool canSave = true;
    bool listSedesEmpty = false;
    bool listVehicleTypeEmpty = false;
    if (_textProductName.text.isEmpty) {
      _validateName = true;
      canSave = false;
    } else
      _validateName = false;

    if (_textPrice.text.isEmpty) {
      _validatePrice = true;
      canSave = false;
    } else
      _validatePrice = false;

    if (_textServiceTime.text.isEmpty) {
      _validatePrice = true;
      canSave = false;
    } else
      _validatePrice = false;

    if (_listLocation.where((f) => f.isSelected??false).toList().length == 0) {
      listSedesEmpty = true;
      canSave = false;
    }

    if (listSedesEmpty || listVehicleTypeEmpty) {
      setState(() {
        MessagesUtils.showAlert(context: context, title: 'Debe agregar Sedes y un tipo de Vehiculo').show();
      });
    }

    if (!_productTypeSimple && !_productTypeSpecial) {
      canSave = false;
      setState(() {
        MessagesUtils.showAlert(context: context, title: 'Debe seleccionar el tipo de Producto').show();
      });
    }

    return canSave;
  }

  void _clearData() {
    _textProductName.text = '';
    _textIvaPercent.text = _initialIvaPercent;
    _textPrice.text = '';
    _textServiceTime.text = '';
    _selectedVehicleTypeString = '';
    _selectedVehicleType = new VehicleType(vehicleType: '');
    _productSelected = new Product();
    _productActive = true;
    _productTypeSpecial = false;
    _productTypeSimple = false;
    setState(() {
      _listLocation.forEach((f) {
        _listLocation[_listLocation.indexOf(f)].isSelected = false;
      });
    });
  }

  void _saveProduct() async {
    if (_validateInputs()) {
      MessagesUtils.showAlertWithLoading(context: context, title: 'Guardando').show();

      //Add new locations at product exist
      _listLocation.where((l) => l.isSelected??false).toList().forEach((f) {
        List<DocumentReference> listFind = (_productSelected.locations??[]).where((e) => e.id == f.id).toList();
        if (listFind.length <= 0) {
          _productSelected.locations?.add(_blocLocation.getDocumentReferenceLocationById(f.id??''));
        }
      });
    
      //Delete locations at product exist
      List<DocumentReference> locListDeleted = <DocumentReference>[];
      _productSelected.locations?.forEach((item) {
        locListDeleted.add(item);
      });
      _productSelected.locations?.forEach((DocumentReference locRefDelete) {
        List<Location> lotionsFind = _listLocation.where((f) => f.id == locRefDelete.id && (f.isSelected??false)).toList();
        if (lotionsFind.length == 0) {
          locListDeleted.removeAt((_productSelected.locations??[]).indexOf(locRefDelete));
        }
      });
      _productSelected.locations?.clear();
      locListDeleted.forEach((d) {
        _productSelected.locations?.add(d);
      });
    
      List<DocumentReference> _newListLocationsReferences = <DocumentReference>[];
      _listLocation.where((d) => d.isSelected??false).toList().forEach((f) {
        _newListLocationsReferences
            .add(_blocLocation.getDocumentReferenceLocationById(f.id??''));
      });

      final product = Product(
          id: _productSelected != null ? _productSelected.id : null,
          productName: _textProductName.text.trim(),
          price: double.tryParse(_textPrice.text.trim()) ?? 0.0,
          ivaPercent: double.tryParse(_textIvaPercent.text.trim()) ?? 0.0,
          vehicleType: _vehicleTypeBloc
              .getVehicleTypeReferenceById(_selectedVehicleType.id??''),
          locations: _productSelected != null
              ? _productSelected.locations
              : _newListLocationsReferences,
          productActive: _productActive,
          vehicleTypeUid: _selectedVehicleType.uid,
          productType: _productTypeSimple ? 'Sencillo' : 'Especial',
          serviceTime: int.tryParse(_textServiceTime.text.trim()) ?? 0,
          companyId: widget.companyId,
      );

      _productBloc.updateProduct(product);

      Navigator.pop(context);
      Navigator.pop(context);

      _clearData();
    }
  }

  //1. product Special, 2. product simple
  void _onChangeRol(int productType, bool? value) {
    setState(() {
      switch (productType) {
        case 1:
          _productTypeSpecial = value ?? false;
          _productTypeSimple = false;
          break;
        case 2:
          _productTypeSpecial = false;
          _productTypeSimple = value ?? false;
          break;
      }
    });
  }
}
