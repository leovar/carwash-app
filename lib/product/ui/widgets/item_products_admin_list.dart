import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/product/bloc/product_bloc.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/product/ui/screens/product_admin_page.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:intl/intl.dart';

class ItemProductAdminList extends StatefulWidget {
  final Function(Product) productSelectCallback;
  final List<Product> productList;
  final int index;

  ItemProductAdminList(
      this.productSelectCallback, this.productList, this.index);

  @override
  State<StatefulWidget> createState() => _ItemProductAdminList();
}

class _ItemProductAdminList extends State<ItemProductAdminList> {
  double _imageWith;
  String _iconVehicle;
  String _vehicleTypeName = '';

  @override
  void initState() {
    super.initState();
    switch (widget.productList[widget.index].vehicleTypeUid) {
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
          widget.productSelectCallback(widget.productList[widget.index]);
        });
      },
      child: itemDecoration(widget.productList[widget.index]),
    );
  }

  Widget itemDecoration(Product _itemProduct) {
    final formatter = NumberFormat("#,###");
    return InkWell(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 70.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: (widget.index % 2 == 0) ? Colors.white : Color(0xFFF1F1F1),
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFD8D8D8),
                width: 1.0,
              ),
            ),
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
                      margin: EdgeInsets.only(left: 7, right: 13),
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
                              _itemProduct.productName,
                              style: TextStyle(
                                fontFamily: "Lato",
                                decoration: TextDecoration.none,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              '\$${formatter.format(_itemProduct.price)}',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontFamily: "Lato",
                                fontSize: 18,
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
                child: _itemProduct.productActive
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
        ),
      ),
      splashColor: Colors.white,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return BlocProvider(
                bloc: ProductBloc(),
                child: ProductAdminPage(
                  currentProduct: _itemProduct,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
