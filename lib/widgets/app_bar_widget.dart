import 'package:flutter/material.dart';
import 'header_menu_page.dart';
import 'package:car_wash_app/User/model/user.dart';

class AppBarWidget extends StatelessWidget{

  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  User usuario;
  bool showDrawer = true;

  AppBarWidget(this._scaffoldKey, this.usuario, this.showDrawer);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AppBar(
      flexibleSpace: HeaderMenuPage(_scaffoldKey, usuario, showDrawer),
      leading: backIcon(context),
    );
  }

  Widget backIcon(BuildContext context){
    if(!showDrawer) {
      return Align(
        alignment: Alignment.center,
        child: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
      );
    } else {
      return Container();
    }
  }

}