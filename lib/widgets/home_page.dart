import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/configuration.dart';
import 'package:car_wash_app/invoices_list/ui/screens/invoices_list_page.dart';
import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/reports/ui/screens/operators_report.dart';
import 'package:car_wash_app/reports/ui/screens/reports_page.dart';
import 'package:car_wash_app/turns/ui/screens/turns_page.dart';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/sysUser.dart';
import 'package:car_wash_app/widgets/select_location_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'gradient_back.dart';
import 'package:car_wash_app/widgets/button_functions.dart';
import 'drawer_page.dart';
import 'package:car_wash_app/invoice/ui/screens/invoice_page.dart';
import 'package:car_wash_app/widgets/app_bar_widget.dart';

import 'keys.dart';
import 'messages_utils.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePage();
  }
}

class _HomePage extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  final _locationBloc = BlocLocation();
  final _blocInvoice = BlocInvoice();
  late UserBloc _userBloc;
  late SysUser _currentUser;
  String _photoUrl = '';
  late DocumentReference _locationReference;
  String _locationName = '';
  bool _isAdministrator = false;
  bool _isCoordinator = false;
  late String _companyId;
  late Location _selectedLocation;
  Configuration _config = Configuration();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _userBloc = BlocProvider.of(context);
    this._getPreferences();
    return WillPopScope(
      child: StreamBuilder(
        stream: _userBloc.streamFirebase,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          switch (snapshot.connectionState) {
            /*case ConnectionState.waiting:
              return indicadorDeProgreso();*/
            default:
              return showSnapShot(snapshot);
          }
        },
      ),
      onWillPop: () {
        return Future(() => false);
      },
    );
  }

  Widget showSnapShot(AsyncSnapshot snapshot) {
    //print('user snapshot $snapshot');
    if (!snapshot.hasData || snapshot.hasError) {
      return indicadorDeProgreso();
    } else {
      return _getUserDb(snapshot);
    }
  }

  Widget _getUserDb(AsyncSnapshot snapshot) {
    if (!snapshot.hasData) {
      return indicadorDeProgreso();
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _userBloc.getUsersByIdStream(snapshot.data!.uid),
      builder: (BuildContext context, AsyncSnapshot userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return indicadorDeProgreso();
        }
        if (userSnapshot.hasError) {
          return Center(child: Text("Error loading user data"));
        }
        if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
          return Center(child: Text("User not found"));
        }
        return _chargeHome(userSnapshot);
      },
    );
  }

  Widget _chargeHome(AsyncSnapshot snapshot) {
    if (snapshot.hasData && !snapshot.data.docs.isEmpty) {
      SysUser user = _userBloc.buildUsersById(snapshot.data.docs);
      this._currentUser = user;
      this._currentUser.photoUrl = _photoUrl;
      this._companyId = user.companyId;
      if (user.isAdministrator ?? false) {
        _isAdministrator = true;
      }
      if (user.isCoordinator ?? false) {
        _isCoordinator = true;
      }
      return homePage();
    } else {
      _deletePreferences();
      this._logOut();
      return indicadorDeProgreso();
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

  homePage() => UpgradeAlert(
        upgrader: Upgrader(durationUntilAlertAgain: Duration(days: 1)),
        child: Scaffold(
          key: _scaffoldKey,
          appBar: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, 65),
            child:
                AppBarWidget(_scaffoldKey, _currentUser.photoUrl ?? '', true),
          ),
          body: Stack(
            children: <Widget>[
              GradientBack(),
              bodyContainer(),
              locationIndicator(),
            ],
          ),
          drawer: DrawerPage(),
        ),
      );

  bodyContainer() => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Flexible(
            child: _backgroundImage(),
          ),
          Flexible(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: _listOptions(),
            ),
          ),
        ],
      );

  Widget _backgroundImage() {
    return Container(
      margin: EdgeInsets.only(top: 60, bottom: 40),
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
  }

  Widget _listOptions() {
    return ListView(
      padding: EdgeInsets.only(right: 17, left: 17),
      scrollDirection: Axis.vertical,
      children: <Widget>[
        ButtonFunctions(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InvoicePage(showDrawer: false)));
          },
          buttonName: "NUEVA FACTURA",
          imageAsset: "assets/images/icon_nueva_factura.png",
          buttonEnabled: _locationName.isNotEmpty ? true : false,
        ),
        SizedBox(
          height: 10.0,
        ),
        ButtonFunctions(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InvoicesListPage(
                  companyId: _companyId,
                  user: _currentUser,
                  locationReference: _locationReference,
                ),
              ),
            );
          },
          buttonName: "FACTURAS",
          imageAsset: "assets/images/icon_facturas.png",
          buttonEnabled: _locationName.isNotEmpty ? true : false,
        ),
        SizedBox(
          height: 10.0,
        ),
        ButtonFunctions(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TurnsPage(
                  companyId: _companyId,
                  user: _currentUser,
                  locationReference: _locationReference,
                ),
              ),
            );
          },
          buttonName: "TURNOS",
          imageAsset: "assets/images/icon_queue.png",
          buttonEnabled: _locationName.isNotEmpty ? true : false,
        ),
        SizedBox(
          height: 10.0,
        ),
        Visibility(
          visible: _isAdministrator,
          child: ButtonFunctions(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ReportsPage(
                          companyId: _companyId,
                        )),
              );
            },
            buttonName: "INFORMES",
            imageAsset: "assets/images/icon_informes.png",
            buttonEnabled: _locationName.isNotEmpty ? true : false,
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        Visibility(
          visible: (_isAdministrator || _isCoordinator),
          child: ButtonFunctions(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => OperatorsReport(
                          locationReference: _locationReference,
                          configuration: _config,
                          companyId: _companyId,
                        )),
              );
            },
            buttonName: "INFORME OPERADORES",
            imageAsset: "assets/images/account-multiple-custom1.png",
            buttonEnabled: _locationName.isNotEmpty ? true : false,
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
      ],
    );
  }

  Widget locationIndicator() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          //borderRadius: BorderRadius.all(Radius.circular(50))
        ),
        child: Stack(
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              child: Text(
                'Sede : $_locationName',
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).primaryColor,
                  fontSize: 17,
                ),
              ),
            ),
            Visibility(
              visible: _isAdministrator,
              child: Container(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(Icons.autorenew),
                  color: Color(0XFF59B258),
                  iconSize: 30,
                  onPressed: () {
                    _changeLocationPreferences();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///Functions

  void _changeLocationPreferences() async {
    Alert(
      context: context,
      title: 'Sede',
      style: MessagesUtils.alertStyle,
      content: SelectLocationWidget(
        locationSelected: _selectedLocation,
        selectLocation: _callBackSelectLocation,
        companyId: _companyId,
      ),
      buttons: [
        DialogButton(
          color: Theme.of(context).colorScheme.secondary,
          child: Text(
            'ACEPTAR',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {});
          },
        )
      ],
    ).show();
  }

  void _callBackSelectLocation(Location locationSelected) {
    _selectedLocation = locationSelected;
    _serLocationPreference(locationSelected);
  }

  void _serLocationPreference(Location locationSelected) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _selectedLocation = locationSelected;
      _locationName = locationSelected.locationName ?? '';
      _locationReference = _locationBloc
          .getDocumentReferenceLocationById(locationSelected.id ?? '');
      pref.setString(Keys.idLocation, locationSelected.id ?? '');
      pref.setString(Keys.locationName, locationSelected.locationName ?? '');
      pref.setString(
          Keys.locationInitCount, locationSelected.initConcec.toString());
      pref.setString(
          Keys.locationFinalCount, locationSelected.finalConsec.toString());
    });
  }

  Future<void> _getPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? idLocation = pref.getString(Keys.idLocation);
    _locationName = pref.getString(Keys.locationName) ?? '';
    _photoUrl = pref.getString(Keys.photoUserUrl) ?? '';
    _companyId = pref.getString(Keys.companyId) ?? '';

    if (idLocation != null && idLocation != '') {
      _locationReference = await _locationBloc.getLocationReference(idLocation);
      try {
        _selectedLocation = await _locationBloc.getLocationById(idLocation);
      } catch (e) {
        print('Error getting location: $e');
        _selectedLocation = Location(companyId: _companyId);
      }
    } else {
      _selectedLocation = Location(companyId: _companyId);
    }

    _blocInvoice.getConfigurationObject(_companyId).then((value) => _config = value);
  }

  Future<void> _deletePreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.idLocation, '');
    pref.setString(Keys.locationName, '');
    pref.setString(Keys.locationInitCount, '0');
    pref.setString(Keys.locationFinalCount, '0');
    pref.setString(Keys.companyId, '');
    pref.setString(Keys.companyName, '');
  }

  Future<void> _logOut() async {
    await _userBloc.singOut();
  }
}
