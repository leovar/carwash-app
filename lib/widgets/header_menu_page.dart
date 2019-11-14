
import 'package:car_wash_app/user/model/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'keys.dart';

class HeaderMenuPage extends StatelessWidget{
  final GlobalKey<ScaffoldState> _scaffoldKey;
  bool showDrawerIcon = true;
  String _userPhotoUrl;

  HeaderMenuPage(this._scaffoldKey, this._userPhotoUrl, this.showDrawerIcon);

  @override
  Widget build(BuildContext context) {
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
              color: showDrawerIcon ? Color(0xFF59B258) : Colors.white,
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
                image: (_userPhotoUrl == null || _userPhotoUrl.isEmpty)
                    ? AssetImage('assets/images/profile_placeholder.png')
                    : NetworkImage(_userPhotoUrl),
              ),
            ),
          ),
        ],
      ),
    );
  }
}