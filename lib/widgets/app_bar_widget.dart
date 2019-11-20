
import 'package:car_wash_app/user/model/user.dart';
import 'package:flutter/material.dart';
import 'header_menu_page.dart';

class AppBarWidget extends StatelessWidget{
  final String photoUserUrl;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  final bool showDrawer;

  AppBarWidget(this._scaffoldKey, this.photoUserUrl, this.showDrawer);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: HeaderMenuPage(_scaffoldKey, photoUserUrl, showDrawer),
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