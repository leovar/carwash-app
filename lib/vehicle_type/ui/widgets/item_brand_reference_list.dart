import 'package:car_wash_app/vehicle_type/model/brand.dart';
import 'package:car_wash_app/vehicle_type/model/brand_reference.dart';
import 'package:flutter/material.dart';

class ItemBrandReferenceList extends StatefulWidget {
  final Brand selectedBrand;
  final BrandReference brandReference;
  final Function(Brand, BrandReference) editBrandReference;

  ItemBrandReferenceList({Key key, this.selectedBrand, this.brandReference, this.editBrandReference});

  @override
  State<StatefulWidget> createState() => _ItemBrandReferenceList();
}

class _ItemBrandReferenceList extends State<ItemBrandReferenceList> {
  double _imageWith;
  String _iconVehicle;
  String _vehicleTypeName = '';

  @override
  void initState() {
    super.initState();
    switch (widget.selectedBrand.vehicleType) {
      case 1:
        _imageWith = 38;
        _iconVehicle = "assets/images/icon_car_admin.png";
        _vehicleTypeName = 'Auto';
        break;
      case 2:
        _imageWith = 37;
        _iconVehicle = 'assets/images/icon_suv_car_admin.png';
        _vehicleTypeName = 'Camioneta';
        break;
      case 3:
        _imageWith = 34;
        _iconVehicle = 'assets/images/icon_motorcycle_admin.png';
        _vehicleTypeName = 'Moto';
        break;
      case 4:
        _imageWith = 34;
        _iconVehicle = 'assets/images/icon_motorcycle_admin.png';
        _vehicleTypeName = 'Bicicleta';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.white,
      onTap: () {
        setState(() {
          widget.editBrandReference(widget.selectedBrand, widget.brandReference);
        });
      },
      child: _itemDecoration(),
    );
  }

  Widget _itemDecoration() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 70.0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: Row(
              children: <Widget>[
                Container(
                  width: 70,
                  margin: EdgeInsets.only(right: 13),
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Flexible(
                          child: Image.asset(_iconVehicle, width: _imageWith),
                        ),
                        Flexible(
                          child: Text(
                            _vehicleTypeName,
                            style: TextStyle(
                              fontFamily: "Lato",
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Color(0xFF59B258),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    //direction: Axis.vertical,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          widget.selectedBrand.brand,
                          style: TextStyle(
                            fontFamily: "Lato",
                            decoration: TextDecoration.none,
                            fontSize: 17,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          widget.brandReference.reference,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontFamily: "Lato",
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 25,
            margin: EdgeInsets.only(right: 8.0),
            child: widget.brandReference.active
                ? Icon(
              Icons.check,
              color: Theme.of(context).primaryColor,
            )
                : Icon(
              Icons.block,
              color: Colors.red,
            ),
          )
        ],
      ),
    );
  }

}