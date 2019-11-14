import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class DrawerPage extends StatefulWidget {
  User usuario;

  DrawerPage(this.usuario);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DrawerPage();
  }
}

class _DrawerPage extends State<DrawerPage> {
  UserBloc userBloc;

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of<UserBloc>(context);
    return drawerPage();
  }

  drawerPage() => Drawer(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              accountName: Text(
                widget.usuario.name??'',
                style: TextStyle(
                  fontFamily: "Lato",
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                  color: Color(0xFF27AEBB),
                ),
              ),
              accountEmail: Text(
                widget.usuario.email??'',
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
                    fit: BoxFit.fill,
                    image: (widget.usuario.photoUrl == null ||
                            widget.usuario.photoUrl.isEmpty)
                        ? AssetImage('assets/images/profile_placeholder.png')
                        : NetworkImage(widget.usuario.photoUrl),
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
            ExpansionTile(
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
                  padding: EdgeInsets.only(left: 90),
                  alignment: Alignment(-1.0, 0.0),
                  child: Text(
                    "Operadores",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.normal,
                      fontSize: 17,
                      color: Color(0xFFAEAEAE),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 90, top: 17),
                  alignment: Alignment(-1.0, 0.0),
                  child: Text(
                    "Usuarios",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.normal,
                      fontSize: 17,
                      color: Color(0xFFAEAEAE),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 90, top: 17),
                  alignment: Alignment(-1.0, 0.0),
                  child: Text(
                    "Servicios",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.normal,
                      fontSize: 17,
                      color: Color(0xFFAEAEAE),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 90, top: 17, bottom: 10),
                  alignment: Alignment(-1.0, 0.0),
                  child: Text(
                    "Sedes",
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.normal,
                      fontSize: 17,
                      color: Color(0xFFAEAEAE),
                    ),
                  ),
                ),
              ],
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
            ListTile(
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
            Expanded(
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
                      userBloc.singOut();
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      );
}
