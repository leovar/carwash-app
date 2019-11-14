import 'dart:core';

import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/widgets/home_page.dart';
import 'package:car_wash_app/widgets/keys.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widgets/gradient_back.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  UserBloc userBloc;
  final blocLocation = BlocLocation();
  final _textUser = TextEditingController();
  final _textPassword = TextEditingController();
  BuildContext _globalContext;

  List<DropdownMenuItem<Location>> _dropdownMenuItems;
  Location _selectedLocation;

  @override
  void initState() {
    super.initState();
    _textUser.text = '';
    _textPassword.text = '';
  }

  @override
  Widget build(BuildContext context) {
    _globalContext = context;
    userBloc = BlocProvider.of(context);
    return _handleCurrentSession();
  }

  ///Valido si el usuario ya se encuentra logueado y lo mando directamente al Home
  Widget _handleCurrentSession() {
    return StreamBuilder(
      stream: userBloc.authStatus,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        //el snapshot tiene la data que se esta retornando
        if (!snapshot.hasData || snapshot.hasError) {
          return loginScreen();
        } else {
          return BlocProvider(
            bloc: UserBloc(),
            child: HomePage(),
          );
        }
      },
    );
  }

  Widget loginScreen() {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            GradientBack(),
            bodyContainer(),
          ],
        ),
      ),
    );
  }

  bodyContainer() => Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              loginHeader(),
              loginFields(),
            ],
          ),
        ),
      );

  loginHeader() => Container(
        margin: EdgeInsets.only(top: 40),
        width: 250,
        height: 86,
        decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage("assets/images/car_wash_movil_logo_blanco.png"),
            ),
            shape: BoxShape.rectangle),
      );

  loginFields() => Container(
        margin: EdgeInsets.only(
          top: 40,
          left: 52,
          right: 52,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            dropDawnLocations(),
            inputUserName(),
            inputPassword(),
            loginButton(),
            loginFacebookGoogle(),
            olvidoContrasena(),
            registrese(),
          ],
        ),
      );

  Widget dropDawnLocations() {
    return StreamBuilder(
      stream: blocLocation.locationsStream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return dropListLocations(snapshot);
        }
      },
    );
  }

  Widget dropListLocations(AsyncSnapshot snapshot) {
    List<Location> locationList =
        blocLocation.buildLocations(snapshot.data.documents);
    _dropdownMenuItems = builDropdownMenuItems(locationList);
    return DropdownButton(
      isExpanded: true,
      items: _dropdownMenuItems,
      value: _selectedLocation,
      onChanged: onChangeDropDawn,
      hint: Text(
        "Seleccione la Sede...",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: Colors.white,
      ),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(
        fontFamily: "AvenirNext",
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
      underline: Container(
        height: 1,
        color: Colors.white,
      ),
    );
  }

  inputUserName() => Container(
        padding: EdgeInsets.symmetric(vertical: 29.0),
        child: TextField(
          maxLines: 1,
          controller: _textUser,
          autofocus: false,
          decoration: InputDecoration(
            contentPadding: const EdgeInsetsDirectional.only(top: 8),
            suffixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(start: 12, top: 12),
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
            labelText: "Usuario",
            labelStyle: TextStyle(
              decoration: TextDecoration.none,
              fontFamily: "AvenirNext",
              color: Colors.white,
              fontSize: 15,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
              ),
            ),
          ),
          cursorColor: Colors.white,
          style: TextStyle(
            fontFamily: "AvenirNext",
            decoration: TextDecoration.none,
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      );

  inputPassword() => Container(
        child: TextField(
          maxLines: 1,
          controller: _textPassword,
          obscureText: true,
          autofocus: false,
          decoration: InputDecoration(
            contentPadding: const EdgeInsetsDirectional.only(top: 8),
            suffixIcon: Padding(
              padding: const EdgeInsetsDirectional.only(start: 12, top: 12),
              child: Icon(
                Icons.lock,
                color: Colors.white,
              ),
            ),
            labelText: "Contraseña",
            labelStyle: TextStyle(
              decoration: TextDecoration.none,
              fontFamily: "AvenirNext",
              color: Colors.white,
              fontSize: 15,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white,
              ),
            ),
          ),
          cursorColor: Colors.white,
          style: TextStyle(
            fontFamily: "AvenirNext",
            decoration: TextDecoration.none,
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      );

  buttonGo() => Padding(
        padding: EdgeInsets.symmetric(vertical: 49),
        child: OutlineButton(
          color: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 58,
          ),
          borderSide: BorderSide(
            width: 1,
            color: Colors.white,
          ),
          child: Text(
            "INGRESAR",
            style: TextStyle(
              fontFamily: "Lato",
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            _emailLogin();
          },
        ),
      );

  loginButton() => Container(
        margin: EdgeInsets.only(top: 49),
        child: Material(
          child: InkWell(
            onTap: () {
              _emailLogin();
            },
            child: Container(
              width: 190.0,
              height: 42.0,
              child: Center(
                child: Text(
                  'INGRESAR',
                  style: TextStyle(
                    fontFamily: "Lato",
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          color: Colors.transparent,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(7.0),
        ),
      );

  loginFacebookGoogle() => Padding(
        padding: EdgeInsets.only(top: 35),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Material(
                  shape: CircleBorder(),
                  color: Colors.transparent,
                  child: Ink.image(
                    image: AssetImage('assets/images/icon_facebook.png'),
                    fit: BoxFit.cover,
                    width: 55.0,
                    height: 55.0,
                    child: InkWell(
                      onTap: () {
                        _facebookLogin();
                      },
                      child: null,
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(left: 30),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Material(
                  shape: CircleBorder(),
                  color: Colors.transparent,
                  child: Ink.image(
                    image: AssetImage('assets/images/icon_google.png'),
                    fit: BoxFit.cover,
                    width: 55.0,
                    height: 55.0,
                    child: InkWell(
                      onTap: () {
                        _googleLogin();
                      },
                      child: null,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  olvidoContrasena() => Container(
        padding: EdgeInsets.only(top: 11),
        child: FlatButton(
          onPressed: () {},
          child: Text(
            "¿Olvidó su contraseña?",
            style: TextStyle(
              fontFamily: "AvenirNext",
              fontWeight: FontWeight.w300,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      );

  registrese() => Container(
        child: FlatButton(
          onPressed: () {},
          child: Text(
            "¿Aún no se ha registrado?",
            style: TextStyle(
              fontFamily: "AvenirNext",
              fontWeight: FontWeight.w300,
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      );

  /// Functions

  bool _validations() {
    //TODO validar que se haya seleccionado una sede, mostrar mensaje de debe seleccionar sede

    if (_selectedLocation != null) {
      return true;
    }
    return false;
  }

  void _registerLogin(FirebaseUser user) {
    _setLocationInPreferences(user);
    userBloc.searchUserByEmail(user.email).then((User currentUser) {
      if (currentUser == null) {
        userBloc.updateUserData(
          User(
            uid: user.uid,
            name: user.displayName,
            email: user.email,
            photoUrl: user.photoUrl,
            lastSignIn: Timestamp.now(),
            active: true,
            isAdministrator: false,
            isCoordinator: false,
            isOperator: false,
          ),
        );
      } else {
        userBloc.updateUserData(
          User(
            uid: currentUser.uid,
            name: user.displayName,
            email: user.email,
            photoUrl: user.photoUrl,
            lastSignIn: Timestamp.now(),
            active: currentUser.active,
            locations: currentUser.locations,
            isAdministrator: currentUser.isAdministrator,
            isCoordinator: currentUser.isCoordinator,
            isOperator: currentUser.isOperator,
          ),
        );
      }
    });
    // TODO este navigate se debe quitar si se coloca la app a validar primero si el usuario esta logueado
    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => HomePage()
      )
    ); */
  }

  void _setLocationInPreferences(FirebaseUser user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.locations, _selectedLocation.id);
    pref.setString(Keys.locationName, _selectedLocation.locationName);
    pref.setString(
        Keys.locationInitCount, _selectedLocation.initConcec.toString());
    pref.setString(
        Keys.locationFinalCount, _selectedLocation.finalConsec.toString());
    pref.setString(Keys.photoUserUrl, user.photoUrl);
  }

  List<DropdownMenuItem<Location>> builDropdownMenuItems(List locations) {
    List<DropdownMenuItem<Location>> listItems = List();
    for (Location documentLoc in locations) {
      listItems.add(
        DropdownMenuItem(
          value: documentLoc,
          child: Text(
            documentLoc.locationName,
          ),
        ),
      );
    }
    return listItems;
  }

  onChangeDropDawn(Location selectedLocation) {
    setState(() {
      _selectedLocation = selectedLocation;
    });
  }

  void _clearTextLogin() {
    _textUser.text = '';
    _textPassword.text = '';
  }

  void _googleLogin() async {
    if (_validations()) {
      try {
        userBloc.singOut();
        FirebaseUser user = await userBloc.signInGoogle();
        if (user != null) {
          this._registerLogin(user);
          _clearTextLogin();
        }
      } on PlatformException catch(e) {
        print('error desde google login  $e');
        MessagesUtils.showAlert(context: context, title: 'Error en login con Google').show();
      }
    }
  }

  void _facebookLogin() async {
    if (_validations()) {
      try {
        FirebaseUser user = await userBloc.signInFacebook();
        if (user != null) {
          this._registerLogin(user);
          _clearTextLogin();
        }
      } on PlatformException catch(e){
        print('error desde facebook login  $e');
        MessagesUtils.showAlert(context: context, title: 'Error en login con Facebook, vuelva a Intentarlo').show();
      }
    }
  }

  void _emailLogin() async {
    if (_validations()) {
      if (_textUser.text.isNotEmpty && _textPassword.text.isNotEmpty) {
        try {
          FirebaseUser user = await userBloc.signInEmail(_textUser.text.trim(), _textPassword.text.trim());
          if (user != null) {
            this._registerLogin(user);
            _clearTextLogin();
          }
        } on PlatformException catch (e) {
          print('error desde email login  $e');
          MessagesUtils.showAlert(context: context, title: 'Usuario o Contraseña incorrectos').show();
        }
      }
    }
  }
}
