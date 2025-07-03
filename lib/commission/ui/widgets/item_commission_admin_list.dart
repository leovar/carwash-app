import 'package:car_wash_app/commission/bloc/bloc_commission.dart';
import 'package:car_wash_app/commission/model/commission.dart';
import 'package:car_wash_app/commission/ui/screens/commission_admin_page.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:intl/intl.dart';

class ItemCommissionAdminList extends StatefulWidget {
  final List<Commission> commissionList;
  final int index;

  ItemCommissionAdminList(this.commissionList, this.index);

  @override
  State<StatefulWidget> createState() => _ItemCommissionAdminList();
}

class _ItemCommissionAdminList extends State<ItemCommissionAdminList> {
  late double _imageWith;
  late String _iconVehicle;
  late String _vehicleTypeName = '';

  @override
  void initState() {
    super.initState();
    switch (widget.commissionList[widget.index].uidVehicleType) {
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
      child: itemDecoration(widget.commissionList[widget.index]),
    );
  }

  Widget itemDecoration(Commission _itemCommission) {
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
                              child:
                                  Image.asset(_iconVehicle, width: _imageWith),
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
                            ),
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
                              _itemCommission.productType??'',
                              style: TextStyle(
                                fontFamily: "Lato",
                                decoration: TextDecoration.none,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: _itemCommission.isValue??false,
                            child: Flexible(
                              child: Text(
                                '\$${formatter.format(_itemCommission.value)}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontFamily: "Lato",
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible: _itemCommission.isPercentage??false,
                            child: Flexible(
                              child: Text(
                                formatter.format(_itemCommission.value) + ' %',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontFamily: "Lato",
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
                bloc: BlocCommission(),
                child: CommissionAdminPage(
                    currentCommission: _itemCommission,
                    iconVehicle: _iconVehicle,
                    vehicleType: _vehicleTypeName),
              );
            },
          ),
        );
      },
    );
  }
}
