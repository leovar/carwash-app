import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/location/ui/screens/create_location_admin_page.dart';
import 'package:car_wash_app/product/bloc/product_bloc.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/product/ui/screens/product_admin_page.dart';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/user/ui/screens/create_user_admin_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:intl/intl.dart';

class ItemLocationAdminList extends StatefulWidget {
  final List<Location> locationList;
  final int index;

  ItemLocationAdminList(this.locationList, this.index);

  @override
  State<StatefulWidget> createState() => _ItemLocationAdminList();
}

class _ItemLocationAdminList extends State<ItemLocationAdminList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.white,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return BlocProvider(
                bloc: BlocLocation(),
                child: CreateLocationAdminPage(
                  currentLocation: widget.locationList[widget.index],
                ),
              );
            },
          ),
        );
      },
      child: itemDecoration(widget.locationList[widget.index]),
    );
  }

  Widget itemDecoration(Location _itemLocation) {
    return ConstrainedBox(
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
              child: Container(
                margin: EdgeInsets.only(left: 20),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //direction: Axis.vertical,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              _itemLocation.locationName,
                              style: TextStyle(
                                fontFamily: "Lato",
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              _itemLocation.nit,
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 25,
              margin: EdgeInsets.only(right: 8.0),
              child: _itemLocation.active
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
    );
  }
}
