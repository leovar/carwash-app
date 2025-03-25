import 'dart:core';

import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/sysUser.dart';
import 'package:car_wash_app/user/ui/screens/register_user.dart';
import 'package:car_wash_app/widgets/select_location_widget.dart';
import 'package:car_wash_app/widgets/home_page.dart';
import 'package:car_wash_app/widgets/keys.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../firebase_options.dart';

import '../../../widgets/gradient_back.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  late UserBloc _userBloc;
  final blocLocation = BlocLocation();
  final _textUser = TextEditingController();
  final _textPassword = TextEditingController();

  late List<DropdownMenuItem<Location>> _dropdownMenuItems;
  Location _selectedLocation = Location();

  @override
  void initState() {
    super.initState();
    _init();
    _textUser.text = '';
    _textPassword.text = '';
  }

  Future _init() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseFirestore firestoreInst = FirebaseFirestore.instance;
    firestoreInst = FirebaseFirestore.instanceFor(app: Firebase.app());
    firestoreInst.settings = const Settings(
      persistenceEnabled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    _userBloc = BlocProvider.of(context);
    return _handleCurrentSession();
  }

  ///Valido si el usuario ya se encuentra logueado y lo mando directamente al Home
  Widget _handleCurrentSession() {
    return StreamBuilder(
      stream: _userBloc.authStatus,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        //el snapshot tiene la data que se esta retornando
        print('Snapshot Login   $snapshot');
        if (!snapshot.hasData || snapshot.hasError) {
          return loginScreen();
        } else {
          _selectedLocation = Location();
          _validateLocationPreferences();

          _deleteCacheDir();
          _deleteAppDir();
          return BlocProvider(bloc: UserBloc(), child: HomePage());
        }
      },
    );
  }

  Future<void> _deleteCacheDir() async {
    final cacheDir = await getTemporaryDirectory();

    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  Future<void> _deleteAppDir() async {
    final appDir = await getApplicationSupportDirectory();

    if (appDir.existsSync()) {
      appDir.deleteSync(recursive: true);
    }
  }

  Widget loginScreen() {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: <Widget>[GradientBack(), bodyContainer()]),
      ),
    );
  }

  bodyContainer() => Center(
    child: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[loginHeader(), loginFields()],
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
      shape: BoxShape.rectangle,
    ),
  );

  loginFields() => Container(
    margin: EdgeInsets.only(top: 40, left: 52, right: 52),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        //dropDawnLocations(),
        inputUserName(),
        inputPassword(),
        _loginButton(),
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
    List<Location> locationList = blocLocation.buildLocations(
      snapshot.data.documents,
    );
    _dropdownMenuItems = builDropdownMenuItems(locationList);
    return DropdownButton(
      isExpanded: true,
      items: _dropdownMenuItems,
      value: _selectedLocation,
      onChanged: onChangeDropDawn,
      hint: Text(
        "Seleccione la Sede...",
        style: TextStyle(color: Colors.white),
      ),
      icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(
        fontFamily: "AvenirNext",
        fontWeight: FontWeight.normal,
        color: Colors.black,
      ),
      underline: Container(height: 1, color: Colors.white),
    );
  }

  inputUserName() => Container(
    padding: EdgeInsets.symmetric(vertical: 29.0),
    child: TextField(
      maxLines: 1,
      controller: _textUser,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: InputDecoration(
        contentPadding: const EdgeInsetsDirectional.only(top: 8),
        suffixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(start: 12, top: 12),
          child: Icon(Icons.person, color: Colors.white),
        ),
        labelText: "Usuario",
        labelStyle: TextStyle(
          decoration: TextDecoration.none,
          fontFamily: "AvenirNext",
          color: Colors.white,
          fontSize: 15,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
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
          child: Icon(Icons.lock, color: Colors.white),
        ),
        labelText: "Contraseña",
        labelStyle: TextStyle(
          decoration: TextDecoration.none,
          fontFamily: "AvenirNext",
          color: Colors.white,
          fontSize: 15,
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
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

  Widget _buttonGo() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 49),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(width: 1, color: Colors.white),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 58),
          /*shape: RoundedRectangleBorder(  //TODO validar como se ve el boton para definir si estas lineas son necesarias
            borderRadius: BorderRadius.circular(10), // Rounded corners
          ),*/
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
  }

  Widget _loginButton() {
    return Container(
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
        border: Border.all(color: Colors.white, width: 1.0),
        borderRadius: BorderRadius.circular(7.0),
      ),
    );
  }

  loginFacebookGoogle() => Padding(
    padding: EdgeInsets.only(top: 35),
    child: Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(shape: BoxShape.circle),
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
            decoration: BoxDecoration(shape: BoxShape.circle),
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
    child: TextButton(
      onPressed: () {
        this._reloadPasswordPressed(_textUser.text.trim());
      },
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

  Widget registrese() {
    return Container(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RegisterUser()),
          );
        },
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
  }

  /// Functions

  bool _validations(String typeLogin) {
    if (typeLogin == 'email') {
      if (_textUser.text.isEmpty || _textPassword.text.isEmpty) {
        MessagesUtils.showAlert(
          context: context,
          title: 'Falta ingresar usuario u contraseña',
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _registerLogin(User user) async {
    String _imageUserProfile = '';
    String _userName = '';
    SysUser? currentUser = await _userBloc.searchUserByEmail(user.email);

    // Select photoUrl
    if (currentUser != null && (currentUser.photoUrl ?? '').isNotEmpty)
      _imageUserProfile = currentUser.photoUrl ?? '';
    else
      _imageUserProfile = user.photoURL ?? '';

    // Select userName
    if (currentUser != null && (currentUser.name ?? '').isNotEmpty)
      _userName = currentUser.name;
    else
      _userName = user.displayName ?? '';

    if (currentUser == null) {
      _userBloc.updateUserData(
        SysUser(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          photoUrl: user.photoURL ?? '',
          lastSignIn: Timestamp.now(),
          active: true,
          isAdministrator: false,
          isCoordinator: false,
          isOperator: false,
        ),
      );
    } else {
      _userBloc.updateUserData(
        SysUser(
          id: currentUser.id,
          uid: currentUser.uid,
          name: _userName,
          email: user.email ?? '',
          photoUrl: _imageUserProfile,
          lastSignIn: Timestamp.now(),
          active: currentUser.active,
          locations: currentUser.locations,
          isAdministrator: currentUser.isAdministrator,
          isCoordinator: currentUser.isCoordinator,
          isOperator: currentUser.isOperator,
        ),
      );
    }

    _setLocationInPreferences(user, _imageUserProfile, _userName);
    // TODO este navigate se debe quitar si se coloca la app a validar primero si el usuario actualmente ya se encuentra logueado
    /* Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => HomePage()
      )
    ); */
  }

  Future<void> _setLocationInPreferences(
    User user,
    String imageUserProfile,
    String userName,
  ) async {
    SysUser? userDatabase = await _userBloc.getCurrentUser();
    if (userDatabase != null) {
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString(Keys.idLocation, '');
      pref.setString(Keys.locationName, '');
      pref.setString(Keys.locationInitCount, '');
      pref.setString(Keys.locationFinalCount, '');
      pref.setString(Keys.photoUserUrl, imageUserProfile);
      pref.setString(Keys.userId, user.uid ?? '');
      pref.setString(Keys.userName, userName);
      pref.setString(Keys.userEmail, user.email ?? '');
      pref.setBool(Keys.isAdministrator, userDatabase.isAdministrator ?? false);
    }
  }

  List<DropdownMenuItem<Location>> builDropdownMenuItems(List locations) {
    List<DropdownMenuItem<Location>> listItems = [];
    for (Location documentLoc in locations) {
      listItems.add(
        DropdownMenuItem(
          value: documentLoc,
          child: Text(documentLoc.locationName??''),
        ),
      );
    }
    return listItems;
  }

  onChangeDropDawn(Location? selectedLocation) {
    setState(() {
      _selectedLocation = selectedLocation ?? new Location();
    });
  }

  void _clearTextLogin() {
    _textUser.text = '';
    _textPassword.text = '';
  }

  void _googleLogin() async {
    if (_validations('google')) {
      try {
        _userBloc.singOut();
        User? user = await _userBloc.signInGoogle();
        if (user != null) {
          this._registerLogin(user);
          _clearTextLogin();
        }
      } on PlatformException catch (e) {
        print('error desde google login  $e');
        MessagesUtils.showAlert(
          context: context,
          title: 'Error en login con Google $e',
        ).show();
      }
    }
  }

  void _facebookLogin() async {
    if (_validations('facebook')) {
      try {
        User? user = await _userBloc.signInFacebook();
        if (user != null) {
          this._registerLogin(user);
          _clearTextLogin();
        }
      } on PlatformException catch (e) {
        print('error desde facebook login  $e');
        MessagesUtils.showAlert(
          context: context,
          title: 'Error en login con Facebook, vuelva a Intentarlo',
        ).show();
      }
    }
  }

  void _emailLogin() async {
    if (_validations('email')) {
      if (_textUser.text.isNotEmpty && _textPassword.text.isNotEmpty) {
        try {
          User? user = await _userBloc.signInEmail(
            _textUser.text.trim(),
            _textPassword.text.trim(),
          );
          if (user != null) {
            this._registerLogin(user);
            _clearTextLogin();
          }
        } on PlatformException {
          MessagesUtils.showAlert(
            context: context,
            title:
                'Usuario o Contraseña incorrectos, recuerde que debe registrarte primero!',
            alertType: AlertType.warning,
          ).show();
        } catch (error) {
          print(error);
        }
      }
    }
  }

  void _validateLocationPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String locationId = pref.getString(Keys.idLocation) ?? '';
    if (locationId.isEmpty) {
      Alert(
        context: context,
        title: 'Sede',
        style: MessagesUtils.alertStyle,
        content: SelectLocationWidget(
          locationSelected: _selectedLocation,
          selectLocation: _callBackSelectLocation,
        ),
        buttons: [
          DialogButton(
            color: Theme.of(context).colorScheme.secondary,
            child: Text('ACEPTAR', style: Theme.of(context).textTheme.labelLarge),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {});
            },
          ),
        ],
      ).show();
    }
  }

  void _callBackSelectLocation(Location locationSelected) {
    _selectedLocation = locationSelected;
    _serLocationPreference(locationSelected);
  }

  void _serLocationPreference(Location locationSelected) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.idLocation, locationSelected.id??'');
    pref.setString(Keys.locationName, locationSelected.locationName??'');
    pref.setString(
      Keys.locationInitCount,
      locationSelected.initConcec.toString(),
    );
    pref.setString(
      Keys.locationFinalCount,
      locationSelected.finalConsec.toString(),
    );
  }

  void _reloadPasswordPressed(String userEmail) {
    if (userEmail.isNotEmpty) {
      Alert(
        context: context,
        title: 'Olvido su Contraseña',
        style: MessagesUtils.alertStyle,
        content: Text(
          'Desea restaurar la contraseña para el usuario $userEmail ?',
        ),
        buttons: [
          DialogButton(
            color: Theme.of(context).colorScheme.secondary,
            child: Text('ACEPTAR', style: Theme.of(context).textTheme.labelLarge),
            onPressed: () {
              _sendEmailResetPassword(userEmail);
              Navigator.of(context).pop();
            },
          ),
          DialogButton(
            color: Theme.of(context).colorScheme.secondary,
            child: Text('CANCELAR', style: Theme.of(context).textTheme.labelLarge),
            onPressed: () {
              Navigator.of(context).pop();
              return;
            },
          ),
        ],
      ).show();
    }
  }

  void _sendEmailResetPassword(String userEmail) {
    _userBloc.resetPasswordUser(userEmail);
  }
}
