import 'package:car_wash_app/vehicle_type/model/brand.dart';
import 'package:flutter/material.dart';

class ItemAdminBrandList extends StatefulWidget {
  final Brand brand;
  final Function(Brand) editBrand;

  ItemAdminBrandList({Key key, this.brand, this.editBrand});

  @override
  State<StatefulWidget> createState() => _ItemAdminBrandList();
}

class _ItemAdminBrandList extends State<ItemAdminBrandList> {
  double _imageWith;
  String _iconVehicle;
  String _vehicleTypeName = '';

  @override
  void initState() {
    super.initState();
    switch (widget.brand.vehicleType) {
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
          widget.editBrand(widget.brand);
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Container(
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
          ),
          Flexible(
            child: Text(
              widget.brand.brand,
              style: TextStyle(
                fontFamily: "Lato",
                decoration: TextDecoration.none,
                fontSize: 17,
              ),
            ),
          ),
        ],
      ),
    );
  }
}