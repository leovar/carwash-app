
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'gradient_back.dart';
import 'package:car_wash_app/widgets/button_functions.dart';
import 'drawer_page.dart';
import 'package:car_wash_app/invoice/ui/screens/invoice_page.dart';
import 'package:car_wash_app/widgets/app_bar_widget.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  UserBloc userBloc;
  User usuario;

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of(context);

    return StreamBuilder(
      stream: userBloc.streamFirebase,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        print(snapshot.connectionState);
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return indicadorDeProgreso();
          case ConnectionState.waiting:
            return indicadorDeProgreso();
          case ConnectionState.active:
            return showSnapShot(snapshot);
          case ConnectionState.done:
            return showSnapShot(snapshot);
          default:
            print("default connection State return NULL");
            return null;
        }
      },
    );
  }

  Widget showSnapShot(AsyncSnapshot snapshot) {
    if (!snapshot.hasData || snapshot.hasError) {
      return indicadorDeProgreso();
    } else {
      print(snapshot.data);
      usuario = User(
        name: snapshot.data.displayName,
        email: snapshot.data.email,
        photoUrl: snapshot.data.photoUrl,
      );
      return homePage();
    }
  }

  indicadorDeProgreso() => Container(
        margin: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 50.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
          ],
        ),
      );

  homePage() => Scaffold(
        key: _scaffoldKey,
        appBar: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 65),
            child: AppBarWidget(_scaffoldKey, usuario, true),
        ),
        body: Stack(
          children: <Widget>[
            GradientBack(),
            bodyContainer(),
          ],
        ),
        drawer: DrawerPage(usuario),
      );

  bodyContainer() => Column(
        children: <Widget>[
          Expanded(
            child: backgroundImage(),
          ),
          Expanded(
            child: listOptions(),
          ),
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

  listOptions() => ListView(
    padding: EdgeInsets.only(right: 17, left: 17, top: 10),
    scrollDirection: Axis.vertical,
    children: <Widget>[
      ButtonFunctions(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => InvoicePage(usuario: usuario, showDrawer: false)));
          },
          buttonName: "NUEVA FACTURA",
          imageAsset: "assets/images/icon_nueva_factura.png"),
      SizedBox(
        height: 10.0,
      ),
      ButtonFunctions(
          onPressed: () {},
          buttonName: "FACTURAS",
          imageAsset: "assets/images/icon_facturas.png"),
      SizedBox(
        height: 10.0,
      ),
      ButtonFunctions(
          onPressed: () {},
          buttonName: "INFORMES",
          imageAsset: "assets/images/icon_informes.png"),
      SizedBox(
        height: 10.0,
      ),
      ButtonFunctions(
          onPressed: () {},
          buttonName: "INFORMES",
          imageAsset: "assets/images/icon_informes.png"),
      SizedBox(
        height: 10.0,
      ),
      ButtonFunctions(
          onPressed: () {},
          buttonName: "INFORMES",
          imageAsset: "assets/images/icon_informes.png"),
    ],
  );
}
