import 'package:flutter/material.dart';
import '../../../widgets/gradient_back.dart';
import '../widgets/button_functions.dart';
import '../../../widgets/header_menu_page.dart';
import '../../../widgets/drawer_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        flexibleSpace: HeaderMenuPage(_scaffoldKey),
        leading: Container(),
      ),
      body: Stack(
        children: <Widget>[
          GradientBack(),
          bodyContainer(),
        ],
      ),
      drawer: DrawerPage(),
    );
  }

  bodyContainer() => Column(
        children: <Widget>[
          backgroundImage(),
          listOptions(),
        ],
      );

  backgroundImage() => Container(
        margin: EdgeInsets.only(top: 40),
        width: 360,
        height: 300,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          image: DecorationImage(
            image: AssetImage("assets/images/img_landing.png"),
          ),
        ),
      );

  listOptions() => Expanded(
        child: ListView(
          padding: EdgeInsets.only(right: 17, left: 17, top: 10),
          scrollDirection: Axis.vertical,
          children: <Widget>[
            ButtonFunctions(
                "NUEVA FACTURA", "assets/images/icon_nueva_factura.png"),
            SizedBox(
              height: 10.0,
            ),
            ButtonFunctions("FACTURAS", "assets/images/icon_facturas.png"),
            SizedBox(
              height: 10.0,
            ),
            ButtonFunctions("INFORMES", "assets/images/icon_informes.png"),
            SizedBox(
              height: 10.0,
            ),
            ButtonFunctions("INFORMES", "assets/images/icon_informes.png"),
            SizedBox(
              height: 10.0,
            ),
            ButtonFunctions("INFORMES", "assets/images/icon_informes.png"),
            SizedBox(
              height: 10.0,
            ),
            ButtonFunctions("INFORMES", "assets/images/icon_informes.png"),
            SizedBox(
              height: 10.0,
            ),
            ButtonFunctions("INFORMES", "assets/images/icon_informes.png"),
            SizedBox(
              height: 10.0,
            ),
            ButtonFunctions("INFORMES", "assets/images/icon_informes.png"),
            SizedBox(
              height: 10.0,
            ),
            ButtonFunctions("INFORMES", "assets/images/icon_informes.png"),
          ],
        ),
      );
}
