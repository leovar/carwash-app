import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/ui/widgets/text_field_input.dart';
import 'package:car_wash_app/vehicle_type/bloc/vehicle_type_bloc.dart';
import 'package:car_wash_app/vehicle_type/model/brand.dart';
import 'package:car_wash_app/vehicle_type/model/brand_reference.dart';
import 'package:car_wash_app/vehicle_type/ui/screens/admin_create_brand.dart';
import 'package:car_wash_app/vehicle_type/ui/widgets/item_brand_reference_list.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class AdminBrandReference extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AdminBrandReference();
}

class _AdminBrandReference extends State<AdminBrandReference> {
  VehicleTypeBloc _vehicleTypeBloc;
  BlocInvoice _blocInvoice = BlocInvoice();
  bool _validateReference = false;
  final _textReferenceName = TextEditingController();
  List<Brand> _listBrands = <Brand>[];
  List<BrandReference> _listBrandReference = [];
  List<DropdownMenuItem<Brand>> _dropdownBrands;
  Brand _selectedBrand;
  BrandReference _referenceToEdit;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _vehicleTypeBloc = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Referencias de Vehículos",
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
          child: _buildPage(),
        ),
      ),
    );
  }

  Widget _buildPage() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 17, horizontal: 16),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 10),
            Flexible(
              child: _addNewBrandButton(),
            ),
            SizedBox(height: 10),
            Flexible(
              child: _dropVehicleBrand(),
            ),
            SizedBox(height: 9),
            Flexible(
              child: Container(
                child: TextFieldInput(
                  autofocus: false,
                  labelText: 'Nombre de Referenica',
                  textController: _textReferenceName,
                  validate: _validateReference,
                  textValidate: 'Escriba el nombre de la referencia',
                ),
              ),
            ),
            SizedBox(height: 9),
            Flexible(
              child: _buttonSave(),
            ),
            SizedBox(height: 9),
            _listBrandReferences(),
          ],
        ),
      ),
    );
  }

  Widget _addNewBrandButton() {
    return Row(
      children: <Widget>[
        FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) {
                return BlocProvider<VehicleTypeBloc>(
                  bloc: VehicleTypeBloc(),
                  child: AdminCreateBrand(),
                );
              }),
            );
          },
        ),
        Container(
          margin: EdgeInsets.only(left: 15),
          child: Text(
            "Agregar Marcas",
            style: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              color: Color(0xFFAEAEAE),
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _dropVehicleBrand() {
    return StreamBuilder(
      stream: _blocInvoice.allBrandsStream(),
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
    if (_blocInvoice.buildBrands(snapshot.data.documents).length >
        _listBrands.length) {
      _listBrands = _blocInvoice.buildBrands(snapshot.data.documents);
    }

    _dropdownBrands = _buildDropdownBrands(_listBrands);
    return DropdownButton(
      autofocus: true,
      isExpanded: true,
      items: _dropdownBrands,
      value: _selectedBrand,
      onChanged: onChangeDropDawn,
      hint: Text(
        "Seleccione la marca del Vehículo...",
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
            _saveReference();
          },
        ),
      ),
    );
  }

  Widget _listBrandReferences() {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 17),
      child: StreamBuilder(
        stream: _vehicleTypeBloc.vehicleBrandReferences(
            _selectedBrand == null ? '1' : _selectedBrand.id),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              return _chargeListBrandReferences(snapshot);
          }
        },
      ),
    );
  }

  Widget _chargeListBrandReferences(AsyncSnapshot snapshot) {
    _listBrandReference =
        _vehicleTypeBloc.buildBrandReference(snapshot.data.documents);
    _listBrandReference.sort((a, b) =>
        a.reference.toLowerCase().compareTo(b.reference.toLowerCase()));
    return ListView.builder(
      itemCount: _listBrandReference.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return ItemBrandReferenceList(
          selectedBrand: _selectedBrand,
          brandReference: _listBrandReference[index],
          editBrandReference: _editBrandReference,
        );
      },
    );
  }

  /// Functions

  List<DropdownMenuItem<Brand>> _buildDropdownBrands(List vehicleBrands) {
    List<DropdownMenuItem<Brand>> listItems = List();
    for (Brand documentLoc in vehicleBrands) {
      listItems.add(
        DropdownMenuItem(
          value: documentLoc,
          child: Text(
            documentLoc.brand,
          ),
        ),
      );
    }
    return listItems;
  }

  onChangeDropDawn(Brand selectedBrand) {
    setState(() {
      _textReferenceName.text = '';
      _selectedBrand = selectedBrand;
    });
  }

  void _saveReference() {
    if (_textReferenceName.text.trim().isNotEmpty) {
      BrandReference ref;
      ref = BrandReference(
        id: _referenceToEdit.id,
        reference: _textReferenceName.text,
        active: true,
      );
          _vehicleTypeBloc.updateBrandReference(_selectedBrand.id, ref);
      _referenceToEdit = null;
      _textReferenceName.text = '';
        } else {
      MessagesUtils.showAlert(
        context: context,
        title: 'Escriba una referencia',
      ).show();
    }
  }

  void _editBrandReference(Brand selectBrand, BrandReference brandRef) {
    _referenceToEdit = brandRef;
    _textReferenceName.text = brandRef.reference;
    _selectedBrand = selectBrand;
  }
}
