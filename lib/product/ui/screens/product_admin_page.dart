import 'package:car_wash_app/invoice/ui/widgets/text_field_input.dart';
import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/location/ui/screens/locations_select_list_page.dart';
import 'package:car_wash_app/product/bloc/product_bloc.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/product/ui/widgets/item_products_admin_list.dart';
import 'package:car_wash_app/vehicle_type/bloc/vehicle_type_bloc.dart';
import 'package:car_wash_app/vehicle_type/model/vehicleType.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:intl/intl.dart';

class ProductAdminPage extends StatefulWidget {

  final Product currentProduct;

  ProductAdminPage({Key key, this.currentProduct});

  @override
  State<StatefulWidget> createState() => _ProductAdminPage();
}

class _ProductAdminPage extends State<ProductAdminPage> {
  ProductBloc _productBloc;
  BlocLocation _blocLocation = BlocLocation();
  VehicleTypeBloc _vehicleTypeBloc = VehicleTypeBloc();

  bool _validateName = false;
  bool _validatePrice = false;
  final _textProductName = TextEditingController();
  final _textPrice = TextEditingController();
  final _textIva = TextEditingController();
  final _textIvaPercent = TextEditingController();
  final double _heightTextField = 60;
  final String _initialIvaPercent = '19';
  List<Product> _productList = <Product>[];
  List<Location> _listLocation = <Location>[];
  List<VehicleType> _lisVehicleType = <VehicleType>[];
  List<DropdownMenuItem<VehicleType>> _dropdownVehicleTypes;
  VehicleType _selectedVehicleType;
  bool _productActive = true;
  Product _productSelected;

  @override
  void initState() {
    super.initState();
    _textIvaPercent.text = _initialIvaPercent;
    if (widget.currentProduct != null) {
      _productSelected = widget.currentProduct;
      _selectProductList();
    }
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
                  maxLines: null,
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
                textValidate: 'Escriba el valor del producto',
                inputType: TextInputType.number,
                textInputFormatter: [
                  WhitelistingTextInputFormatter(RegExp("^[0-9.]*"))
                ],
                onFinalEditText: _onValueIvaPriceChanged,
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
                maxLength: 2,
                onFinalEditText: _onValueIvaPriceChanged,
              ),
            ),
            SizedBox(height: 9),
            Container(
              height: 48,
              child: TextFieldInput(
                labelText: 'Valor con Iva',
                textController: _textIva,
                inputType: TextInputType.number,
                enable: false,
                textInputFormatter: [
                  WhitelistingTextInputFormatter(RegExp("^[0-9.]*"))
                ],
              ),
            ),
            SizedBox(height: 9),
            _locationsToSelect(),
            SizedBox(height: 9),
            Flexible(
              child: _dropVehicleType(),
            ),
            SizedBox(height: 9),
            Flexible(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _productActive,
                    onChanged: (bool value) {
                      setState(() {
                        _productActive = value;
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
      stream: _blocLocation.locationsListStream,
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
    if (_blocLocation.buildLocations(snapshot.data.documents).length > _listLocation.length) {
      _listLocation = _blocLocation.buildLocations(snapshot.data.documents);
      if (widget.currentProduct != null) {
        _selectProductList();
      }
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
                '${_listLocation.where((f) => f.isSelected).toList().length} sedes agregadas',
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

  Widget _dropVehicleType() {
    return StreamBuilder(
      stream: _vehicleTypeBloc.vehicleTypeStream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return _getDataVehicleTypeList(snapshot);
        }
      },
    );
  }
  Widget _getDataVehicleTypeList(AsyncSnapshot snapshot) {
    if (_vehicleTypeBloc.buildVehicleType(snapshot.data.documents).length > _lisVehicleType.length) {
      _lisVehicleType = _vehicleTypeBloc.buildVehicleType(snapshot.data.documents);
      if (widget.currentProduct != null) {
        _selectProductList();
      }
    }
    _dropdownVehicleTypes = _buildDropdownVehicleTypes(_lisVehicleType);
    return DropdownButton(
      isExpanded: true,
      items: _dropdownVehicleTypes,
      value: _selectedVehicleType,
      onChanged: onChangeDropDawn,
      hint: Text(
        "Seleccione el Typo de Vehiculo...",
        style: TextStyle(
          color: Color(0xFFAEAEAE),
        ),
      ),
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: Color(0xFFAEAEAE),
        size: 30,
      ),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(
        fontFamily: "AvenirNext",
        fontWeight: FontWeight.normal,
        color: Color(0xFFAEAEAE),
      ),
      underline: Container(
        height: 1,
        color: Color(0xFFAEAEAE),
      ),
    );
  }

  Widget _buttonSave() {
    return Container(
      height: 100,
      child: Align(
        alignment: Alignment.center,
        child: RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
          color: Color(0xFF59B258),
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
    _textProductName.text = _productSelected.productName;
    _textIvaPercent.text = _productSelected.ivaPercent;
    _textIva.text = _productSelected.iva.toString();
    _textPrice.text = _productSelected.price.toStringAsFixed(2);
    _productActive = _productSelected.productActive ?? true;
    _selectedVehicleType = _lisVehicleType.length > 0
        ? _lisVehicleType.firstWhere((f) => f.id == _productSelected.vehicleType.documentID)
        : null;
    _listLocation.forEach((Location loc) {
      List<DocumentReference> dr = _productSelected.locations
          .where((e) => e.documentID == loc.id)
          .toList();
      if (dr.length > 0) {
        _listLocation[_listLocation.indexOf(loc)].isSelected = true;
      } else {
        _listLocation[_listLocation.indexOf(loc)].isSelected = false;
      }
    });
  }

  ///Functions Locations
  void _setLocationsDb(List<Location> locationsListSelected) {
    _listLocation = locationsListSelected;
  }

  ///Functions VehicleType
  List<DropdownMenuItem<VehicleType>> _buildDropdownVehicleTypes(
      List vehicleTypes) {
    List<DropdownMenuItem<VehicleType>> listItems = List();
    for (VehicleType documentLoc in vehicleTypes) {
      listItems.add(
        DropdownMenuItem(
          value: documentLoc,
          child: Text(
            documentLoc.vehicleType,
          ),
        ),
      );
    }
    return listItems;
  }

  onChangeDropDawn(VehicleType selectedVehicleType) {
    setState(() {
      _selectedVehicleType = selectedVehicleType;
    });
  }

  void _onValueIvaPriceChanged() {
    if (_textIvaPercent.text.isEmpty) _textIvaPercent.text = '0';
    if (_textPrice.text.isNotEmpty && _textIvaPercent.text.isNotEmpty) {
      double price = double.tryParse(_textPrice.text) ?? 0.0;
      double ivaPercent = double.tryParse(_textIvaPercent.text) ?? 0.0;
      setState(() {
        _textIva.text = (price * (ivaPercent / 100)).toStringAsFixed(2);
      });
    } else {
      setState(() {
        _textIva.text = '0';
      });
    }
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

    if (_listLocation.where((f) => f.isSelected).toList().length == 0) {
      listSedesEmpty = true;
      canSave = false;
    }

    if (_selectedVehicleType == null) {
      listVehicleTypeEmpty = true;
      canSave = false;
    }

    if (listSedesEmpty || listVehicleTypeEmpty) {
      setState(() {
        MessagesUtils.showAlert(context: context, title: 'Debe agregar Sedes y un tipo de Vehiculo').show();
      });
    }

    return canSave;
  }

  void _clearData() {
    _textProductName.text = '';
    _textIvaPercent.text = _initialIvaPercent;
    _textIva.text = '';
    _textPrice.text = '';
    _selectedVehicleType = null;
    _productSelected = null;
    _productActive = true;
    setState(() {
      _listLocation.forEach((f) {
        _listLocation[_listLocation.indexOf(f)].isSelected = false;
      });
    });
  }

  void _saveProduct() async {
    if (_validateInputs()) {
      MessagesUtils.showAlertWithLoading(context: context, title: 'Guardando')
          .show();

      //Add new locations at product exist
      if (_productSelected != null) {
        _listLocation.where((l) => l.isSelected).toList().forEach((f) {
          List<DocumentReference> listFind = _productSelected.locations
              .where((e) => e.documentID == f.id)
              .toList();
          if (listFind.length <= 0) {
            _productSelected.locations
                .add(_blocLocation.getDocumentReferenceLocationById(f.id));
          }
        });
      }

      //Delete locations at product exist
      if (_productSelected != null) {
        List<DocumentReference> locListDeleted = <DocumentReference>[];
        _productSelected.locations.forEach((item) {
          locListDeleted.add(item);
        });
        _productSelected.locations.forEach((DocumentReference locRefDelete) {
          List<Location> lotionsFind = _listLocation.where((f) => f.id == locRefDelete.documentID && f.isSelected).toList();
          if (lotionsFind.length == 0) {
            locListDeleted.removeAt(_productSelected.locations.indexOf(locRefDelete));
          }
        });
        _productSelected.locations.clear();
        locListDeleted.forEach((d) {
          _productSelected.locations.add(d);
        });
      }

      List<DocumentReference> _newListLocationsReferences = <DocumentReference>[];
      _listLocation.where((d) => d.isSelected).toList().forEach((f) {
        _newListLocationsReferences
            .add(_blocLocation.getDocumentReferenceLocationById(f.id));
      });

      final product = Product(
          id: _productSelected != null ? _productSelected.id : null,
          productName: _textProductName.text.trim(),
          price: double.tryParse(_textPrice.text.trim()) ?? 0.0,
          iva: double.tryParse(_textIva.text.trim()) ?? 0.0,
          ivaPercent: _textIvaPercent.text.trim(),
          vehicleType: _vehicleTypeBloc
              .getVehicleTypeReferenceById(_selectedVehicleType.id),
          locations: _productSelected != null
              ? _productSelected.locations
              : _newListLocationsReferences,
          productActive: _productActive,
          vehicleTypeUid: _selectedVehicleType.uid);

      _productBloc.updateProduct(product);

      Navigator.pop(context);
      Navigator.pop(context);

      _clearData();
    }
  }
}
