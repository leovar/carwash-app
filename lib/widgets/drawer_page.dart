import 'package:flutter/material.dart';

class DrawerPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DrawerPage();
  }
}

class _DrawerPage extends State<DrawerPage>{

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            accountName: Text(
              "Leonardo Valencia Restrepo",
              style: TextStyle(
                fontFamily: "Lato",
                fontWeight: FontWeight.w600,
                fontSize: 17,
                color: Color(0xFF27AEBB),
              ),
            ),
            accountEmail: Text(
              "lvalenr@hotmail.com",
            ),
            otherAccountsPictures: <Widget>[
              IconButton(
                iconSize: 35,
                alignment: Alignment.centerLeft,
                icon: Icon(
                  Icons.menu,
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
                  image: AssetImage("assets/images/profile21.jpg"),
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
        ],
      ),
    );
  }
}