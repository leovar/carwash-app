import 'package:flutter/material.dart';

class HeaderMenuPage extends StatelessWidget{
  GlobalKey<ScaffoldState> _scaffoldKey;

  HeaderMenuPage(this._scaffoldKey);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      margin: EdgeInsets.only(top: 25),
      height: 65,
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            iconSize: 35,
            alignment: Alignment.centerLeft,
            icon: Icon(
              Icons.menu,
              color: Color(0xFF59B258),
            ),
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();
            },
          ),
          Container(
            width: 220,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                fit: BoxFit.cover,
                image:
                AssetImage("assets/images/car_wash_movil_logo_color.png"),
              ),
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              border: Border.all(
                width: 2,
                color: Colors.grey,
              ),
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage("assets/images/profile21.jpg"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}