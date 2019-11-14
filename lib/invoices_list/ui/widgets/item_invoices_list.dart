import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoices_list/model/invoice_list_model.dart';
import 'package:car_wash_app/vehicle/bloc/bloc_vehicle.dart';
import 'package:car_wash_app/vehicle/model/vehicle.dart';
import 'package:car_wash_app/vehicle_type/bloc/vehicle_type_bloc.dart';
import 'package:car_wash_app/vehicle_type/model/vehicleType.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ItemInvoicesList extends StatefulWidget {
  List<Invoice> listInvoices;
  List<InvoiceListModel> listInvoicesModel;
  int index;
  bool updateDate;

  ItemInvoicesList(
      {Key key,
      this.listInvoices,
      this.listInvoicesModel,
      this.index,
      this.updateDate});

  @override
  State<StatefulWidget> createState() => _ItemInvoicesList();
}

class _ItemInvoicesList extends State<ItemInvoicesList> {
  final _blocVehicle = BlocVehicle();
  final _blocVehicleType = VehicleTypeBloc();
  double _imageWith;
  String _iconVehicle;

  @override
  void initState() {
    super.initState();
    switch (widget.listInvoices[widget.index].uidVehicleType) {
      case 1:
        _imageWith = 38;
        _iconVehicle = "assets/images/icon_car_admin.png";
        break;
      case 2:
        _imageWith = 37;
        _iconVehicle = 'assets/images/icon_suv_car_admin.png';
        break;
      case 3:
        _imageWith = 34;
        _iconVehicle = 'assets/images/icon_motorcycle_admin.png';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.updateDate) {
      //this._getInfoVehicles();
    }
    return InkWell(
      splashColor: Colors.white,
      onTap: () {},
      child: _itemDecoration(widget.listInvoices[widget.index]),
    );
  }

  Widget _itemDecoration(Invoice invoiceList) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: (widget.index % 2 == 0) ? Colors.white : Color(0xFFF1F1F1),
        /*border: Border(
          bottom: BorderSide(
            color: Color(0xFFD8D8D8),
            width: 1.0,
          ),
        ),*/
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            width: 55,
            margin: EdgeInsets.only(left: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset(_iconVehicle, width: _imageWith),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 185.0,
            child: Wrap(
              direction: Axis.vertical,
              children: <Widget>[
                Text(
                  invoiceList.placa ?? '',
                  style: TextStyle(
                    color: Color(0xFF787A71),
                    fontFamily: "Lato",
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
                Visibility(
                  visible:
                      (invoiceList.userOperatorName != null) ? true : false,
                  child: Text(
                    invoiceList.userOperatorName ?? '',
                    style: TextStyle(
                      color: Color(0xFF787A71),
                      fontFamily: "Lato",
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          //Text(invoiceList.totalPrice.toString()),
          Container(
            width: 55,
            alignment: Alignment.centerRight,
            child: Text(
              invoiceList.consecutive.toString(),
              style: TextStyle(
                color: Color(0xFF59B258),
                fontFamily: "Lato",
                fontWeight: FontWeight.bold,
                fontSize: 17.0,
              ),
            ),
          )
        ],
      ),
    );
  }
}
