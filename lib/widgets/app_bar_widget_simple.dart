
import 'package:flutter/material.dart';

class SimpleAppBarWidget extends StatelessWidget{

  SimpleAppBarWidget();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: _header(),
      leading: _backIcon(context),
    );
  }

  Widget _backIcon(BuildContext context){
    return Align(
      alignment: Alignment.center,
      child: IconButton(
        icon: Icon(Icons.arrow_back),
        iconSize: 30,
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _header() {
    return Container(
      margin: EdgeInsets.only(top: 25),
      height: 65,
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
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
        ],
      ),
    );
  }
}