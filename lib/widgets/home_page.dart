import 'package:car_wash_app/invoices_list/ui/screens/invoices_list_page.dart';
import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'gradient_back.dart';
import 'package:car_wash_app/widgets/button_functions.dart';
import 'drawer_page.dart';
import 'package:car_wash_app/invoice/ui/screens/invoice_page.dart';
import 'package:car_wash_app/widgets/app_bar_widget.dart';

import 'keys.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  final _locationBloc = BlocLocation();
  UserBloc userBloc;
  User usuario;
  DocumentReference _locationReference;
  String _locationName = '';

  @override
  Widget build(BuildContext context) {
    userBloc = BlocProvider.of(context);
    this._getPreferences();
    return StreamBuilder(
      stream: userBloc.streamFirebase,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        print('user snapshot $snapshot');
        print(snapshot.connectionState);
        switch (snapshot.connectionState) {
          /*case ConnectionState.waiting:
            return indicadorDeProgreso();*/
          default:
            return showSnapShot(snapshot);
        }
      },
    );
  }

  Widget showSnapShot(AsyncSnapshot snapshot) {
    //print('user snapshot $snapshot');
    if (!snapshot.hasData || snapshot.hasError) {
      return indicadorDeProgreso();
    } else {
      print(snapshot.data);
      return _getUserDb(snapshot);
    }
  }

  Widget _getUserDb(AsyncSnapshot snapshot) {
    return StreamBuilder(
      stream: userBloc.getUsersByIdStream(snapshot.data.uid),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return indicadorDeProgreso();
          default:
            return _chargeHome(snapshot);
        }
      },
    );
  }

  Widget _chargeHome(AsyncSnapshot snapshot) {
    User user = userBloc.buildUsersById(snapshot.data.documents);
    usuario = user;
    return homePage();
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
          child: AppBarWidget(_scaffoldKey, usuario.photoUrl, true),
        ),
        body: Stack(
          children: <Widget>[
            GradientBack(),
            bodyContainer(),
            locationIndicator(),
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            InvoicePage(usuario: usuario, showDrawer: false)));
              },
              buttonName: "NUEVA FACTURA",
              imageAsset: "assets/images/icon_nueva_factura.png"),
          SizedBox(
            height: 10.0,
          ),
          ButtonFunctions(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => InvoicesListPage(
                              user: usuario,
                              locationReference: _locationReference,
                            )));
              },
              buttonName: "FACTURAS",
              imageAsset: "assets/images/icon_facturas.png"),
          SizedBox(
            height: 10.0,
          ),
          ButtonFunctions(
              onPressed: () {},
              buttonName: "INFORMES",
              imageAsset: "assets/images/icon_informes.png"),
        ],
      );

  Widget locationIndicator() {
    return Align(
      alignment: Alignment(-0.93, -0.97),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(50))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'Sede : $_locationName',
              style: TextStyle(
                fontFamily: "Lato",
                decoration: TextDecoration.none,
                fontWeight: FontWeight.normal,
                color: Theme.of(context).primaryColor,
                fontSize: 17,
              ),
            )
          ],
        ),
      ),
    );
  }

  ///Functions

  void _getPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String idLocation = pref.getString(Keys.idLocation);
    _locationReference = await _locationBloc.getLocationReference(idLocation);
    _locationName = pref.getString(Keys.locationName);
  }
}
