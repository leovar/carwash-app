
import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/vehicle_type/bloc/vehicle_type_bloc.dart';
import 'package:car_wash_app/vehicle_type/model/brand.dart';
import 'package:car_wash_app/vehicle_type/ui/widgets/item_admin_brand_list.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class AdminCreateBrand extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AdminCreateBrand();
}

class _AdminCreateBrand extends State<AdminCreateBrand> {
  late VehicleTypeBloc _vehicleTypeBloc;
  BlocInvoice _blocInvoice = BlocInvoice();
  final _textReferenceName = TextEditingController();
  bool _validateReference = false;
  List<Brand> _listBrands = <Brand>[];
  late Brand _brandToEdit;
  late FocusNode myFocusNode;
  bool _typeCar = false;
  bool _typeSuperBike = false;
  bool _typeBike = false;

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _textReferenceName.dispose();
    myFocusNode.dispose();
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
         "Marcas de Vehículos",
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
            SizedBox(height: 12),
            Flexible(
              child: Container(
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nombre de Marca',
                  ),
                  controller: _textReferenceName,
                  focusNode: myFocusNode,
                ),
              ),
            ),
            SizedBox(height: 9),
            Flexible(
              child: _buttonSave(),
            ),
            SizedBox(height: 9),
            Flexible(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _typeCar,
                    onChanged: (bool? value) {
                      _onChangeRol(1, value);
                    },
                    checkColor: Colors.white,
                    activeColor: Color(0xFF59B258),
                  ),
                  Text(
                    "Carro",
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
                    value: _typeSuperBike,
                    onChanged: (bool? value) {
                      _onChangeRol(3, value);
                    },
                    checkColor: Colors.white,
                    activeColor: Color(0xFF59B258),
                  ),
                  Text(
                    "Moto",
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
                    value: _typeBike,
                    onChanged: (bool? value) {
                      _onChangeRol(4, value);
                    },
                    checkColor: Colors.white,
                    activeColor: Color(0xFF59B258),
                  ),
                  Text(
                    "Bicicleta",
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
            _listBrand(),
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
            _saveBrand();
          },
        ),
      ),
    );
  }

  Widget _listBrand() {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 17),
      child: StreamBuilder(
        stream: _blocInvoice.allBrandsStream(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            default:
              return _chargeListBrand(snapshot);
          }
        },
      ),
    );
  }

  Widget _chargeListBrand(AsyncSnapshot snapshot) {
    _listBrands = _blocInvoice.buildBrands(snapshot.data.documents);
    _listBrands.sort((a, b) => (a.brand??'').toLowerCase().compareTo((b.brand??'').toLowerCase()));
    myFocusNode.requestFocus();
    return ListView.builder(
      itemCount: _listBrands.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return ItemAdminBrandList(
          brand: _listBrands[index],
          editBrand: _editBrand,
        );
      },
    );
  }

  /// Functions

  void _saveBrand() {
    if (_textReferenceName.text.trim().isNotEmpty) {
      int selectType = 1;
      if (_typeSuperBike)
        selectType = 3;
      else if (_typeBike)
        selectType = 4;

      Brand ref;
      List<Brand> findBrand = _listBrands.where((elm) => (elm.brand??'').toLowerCase() == ((_textReferenceName.text??'').toLowerCase().trim())).toList();

      if (findBrand.length > 0) {
        MessagesUtils.showAlert(
          context: context,
          title: 'Ya existe una marca con ese nombre',
        ).show();
      } else if(_typeCar || _typeSuperBike || _typeBike) {
        ref = Brand(
          id: _brandToEdit.id,
          brand: _textReferenceName.text,
          vehicleType: selectType,
        );
        _vehicleTypeBloc.updateBrand(ref);
        _clearData();
              setState(() {

        });
      } else {
        MessagesUtils.showAlert(
          context: context,
          title: 'Debe seleccionar un tipo de vehículo',
        ).show();
      }
    } else {
      MessagesUtils.showAlert(
        context: context,
        title: 'Escriba una marca',
      ).show();
    }
  }

  void _clearData() {
    _brandToEdit = new Brand();
    _textReferenceName.text = '';
    _typeCar = false;
    _typeSuperBike = false;
    _typeBike = false;
  }

  void _editBrand(Brand? selectBrand) {
    _brandToEdit = selectBrand ?? new Brand();
    _textReferenceName.text = selectBrand?.brand ?? '';
    _onChangeRol(selectBrand?.vehicleType, true);
  }

  //1. administrator, 2. coordinator, 3. Operator
  void _onChangeRol(int? rol, bool? value) {
    setState(() {
      switch (rol) {
        case 1:
          _typeCar = value ?? false;
          _typeSuperBike = false;
          _typeBike = false;
          break;
        case 3:
          _typeCar = false;
          _typeSuperBike = value ?? false;
          _typeBike = false;
          break;
        case 4:
          _typeCar = false;
          _typeSuperBike = false;
          _typeBike = value ?? false;
          break;
      }
    });
  }
}


