import 'package:car_wash_app/Usuario/model/usuario.dart';
import 'package:car_wash_app/widgets/header_menu_page.dart';
import 'package:flutter/material.dart';
import 'package:car_wash_app/widgets/drawer_page.dart';
import 'package:car_wash_app/widgets/gradient_back.dart';

class FacturaPage extends StatefulWidget {
  final Usuario usuario;

  FacturaPage(this.usuario);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FacturaPage();
  }
}

class _FacturaPage extends State<FacturaPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        flexibleSpace: HeaderMenuPage(_scaffoldKey, widget.usuario),
        leading: Container(),
      ),
      body: Stack(
        children: <Widget>[
          GradientBack(),
          bodyContainer(),
        ],
      ),
      drawer: DrawerPage(widget.usuario),
    );
  }

  bodyContainer() => Column(
        children: <Widget>[
          Material(
            elevation: 16,
            child: tabBar(),
          ),
        ],
      );

  tabBar() => TabBar(
        controller: _tabController,
        indicatorColor: Color(0xFF59B258),
        indicatorWeight: 3,
        unselectedLabelColor: Color(0xFF27AEBB),
        labelColor: Color(0xFF59B258),
        labelStyle: TextStyle(
          color: Color(0xFF59B258),
        ),
        tabs: <Widget>[
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Icon(Icons.directions_car),
                Text(
                  "Auto",
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Icon(Icons.airport_shuttle),
                Expanded(
                  child: Text(
                    "Camioneta",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Icon(Icons.motorcycle),
                Text(
                  "Moto",
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
