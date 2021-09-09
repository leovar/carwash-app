import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/ui/screens/locations_admin_page.dart';
import 'package:car_wash_app/product/bloc/product_bloc.dart';
import 'package:car_wash_app/product/ui/screens/product_list_admin_page.dart';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/user/ui/screens/user_profile_page.dart';
import 'package:car_wash_app/user/ui/screens/users_admin_page.dart';
import 'package:car_wash_app/vehicle_type/bloc/vehicle_type_bloc.dart';
import 'package:car_wash_app/vehicle_type/ui/screens/admin_brand_reference.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'keys.dart';

class DrawerPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DrawerPage();
}

class _DrawerPage extends State<DrawerPage> {
  UserBloc userBloc;
  String _photoUser = '';
  String _userName = '';
  String _userEmail = '';
  User _currentUser;
  bool _showInfoAdministrator = false;

  @override
  void initState() {
    super.initState();
    _getPreferences();
  }

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);
    return drawerPage();
  }

  drawerPage() => Drawer(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Flexible(
              flex: 5,
              child: Column(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    accountName: Text(
                      _userName ?? '',
                      style: TextStyle(
                        fontFamily: "Lato",
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                        color: Color(0xFF27AEBB),
                      ),
                    ),
                    accountEmail: Text(
                      _userEmail ?? '',
                    ),
                    otherAccountsPictures: <Widget>[
                      IconButton(
                        iconSize: 35,
                        alignment: Alignment.centerLeft,
                        icon: Icon(
                          Icons.arrow_back,
                          color: Color(0xFF59B258),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                    currentAccountPicture: Container(
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
                          image: (_photoUser == null || _photoUser.isEmpty)
                              ? AssetImage(
                                  'assets/images/profile_placeholder.png')
                              : NetworkImage(_photoUser),
                        ),
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Inicio",
                      style: TextStyle(
                        fontFamily: "Lato",
                        fontWeight: FontWeight.normal,
                        fontSize: 17,
                        color: Color(0xFF27AEBB),
                      ),
                    ),
                    leading: Ink.image(
                      image: AssetImage("assets/images/icon_home.png"),
                      width: 22,
                    ),
                  ),
                  Visibility(
                    visible: _showInfoAdministrator,
                    child: ExpansionTile(
                      title: Text(
                        "Administración",
                        style: TextStyle(
                          fontFamily: "Lato",
                          fontWeight: FontWeight.normal,
                          fontSize: 17,
                          color: Color(0xFF27AEBB),
                        ),
                      ),
                      leading: Ink.image(
                        image: AssetImage("assets/images/icon_admin.png"),
                        width: 22,
                      ),
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 90, top: 17),
                          alignment: Alignment(-1.0, 0.0),
                          child: InkWell(
                            child: Text(
                              "Usuarios",
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontWeight: FontWeight.normal,
                                fontSize: 17,
                                color: Color(0xFFAEAEAE),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return BlocProvider(
                                    bloc: UserBloc(),
                                    child: UsersAdminPage(),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 90, top: 17),
                          alignment: Alignment(-1.0, 0.0),
                          child: InkWell(
                            child: Text(
                              "Servicios",
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontWeight: FontWeight.normal,
                                fontSize: 17,
                                color: Color(0xFFAEAEAE),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return BlocProvider<ProductBloc>(
                                    bloc: ProductBloc(),
                                    child: ProductListAdminPage(),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 90, top: 17),
                          alignment: Alignment(-1.0, 0.0),
                          child: InkWell(
                            child: Text(
                              "Sedes",
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontWeight: FontWeight.normal,
                                fontSize: 17,
                                color: Color(0xFFAEAEAE),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return BlocProvider<BlocLocation>(
                                    bloc: BlocLocation(),
                                    child: LocationsAdminPage(),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.only(left: 90, top: 17, bottom: 10),
                          alignment: Alignment(-1.0, 0.0),
                          child: InkWell(
                            child: Text(
                              "Referencias de Vehiculo",
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontWeight: FontWeight.normal,
                                fontSize: 17,
                                color: Color(0xFFAEAEAE),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return BlocProvider<VehicleTypeBloc>(
                                    bloc: VehicleTypeBloc(),
                                    child: AdminBrandReference(),
                                  );
                                }),
                              );
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Vehículos",
                      style: TextStyle(
                        fontFamily: "Lato",
                        fontWeight: FontWeight.normal,
                        fontSize: 17,
                        color: Color(0xFF27AEBB),
                      ),
                    ),
                    leading: Ink.image(
                      image: AssetImage("assets/images/icon_car_admin.png"),
                      width: 25,
                    ),
                  ),
                  InkWell(
                    child: ListTile(
                      title: Text(
                        "Perfil",
                        style: TextStyle(
                          fontFamily: "Lato",
                          fontWeight: FontWeight.normal,
                          fontSize: 17,
                          color: Color(0xFF27AEBB),
                        ),
                      ),
                      leading: Icon(
                        Icons.perm_identity,
                        color: Color(0xFF59B258),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserProfilePage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Flexible(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          child: Text('Version 1.0.7'),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Color(0xFFD8D8D8),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              "Salir",
                              style: TextStyle(
                                fontFamily: "Lato",
                                fontWeight: FontWeight.normal,
                                fontSize: 17,
                                color: Color(0xFF27AEBB),
                              ),
                            ),
                            leading: Ink.image(
                              image: AssetImage("assets/images/icon_logout.png"),
                              width: 25,
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _deleteLocationPreference();
                              _logOut();
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );

  void _getPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String userId = pref.getString(Keys.userId);
    setState(() {
      _photoUser = pref.getString(Keys.photoUserUrl);
      _userName = pref.getString(Keys.userName);
      _userEmail = pref.getString(Keys.userEmail);
      _showInfoAdministrator = pref.getBool(Keys.isAdministrator);
    });
  }

  Future<void> _deleteLocationPreference() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.idLocation, '');
    pref.setString(Keys.locationName, '');
    pref.setString(Keys.locationInitCount, '0');
    pref.setString(Keys.locationFinalCount, '0');
  }

  Future<void> _logOut() async {
    await userBloc.singOut();
  }
}
