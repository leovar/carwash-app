import 'dart:core' as prefix0;
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../widgets/gradient_back.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginPage();
  }
}

class Company {
  int Id;
  String name;
  Color color;

  Company(
    this.Id,
    this.name,
    this.color,
  );

  static List<Company> getCompanies() {
    return <Company>[
      Company(1, 'Molinos', Colors.red),
      Company(1, 'Palmas', Colors.white),
      Company(1, 'La Ceja', Colors.amberAccent),
      Company(1, 'La Central', Colors.purple),
    ];
  }
}

class ColorModel {
  String colorName;
  Color color;

  ColorModel({this.colorName, this.color});
}

List<ColorModel> _colors = [
  ColorModel(color: Colors.blue, colorName: "Blue"),
  ColorModel(color: Colors.purple, colorName: "Purple"),
  ColorModel(color: Colors.pink, colorName: "Pink"),
  ColorModel(color: Colors.teal, colorName: "Teal"),
  ColorModel(color: Colors.amber, colorName: "Amber"),
  ColorModel(color: Colors.black, colorName: "Black"),
];
Color _selectedColor = Colors.blue;

class _LoginPage extends State<LoginPage> {
  List<Company> _companies = Company.getCompanies();
  List<DropdownMenuItem<Company>> _dropdownMenuItems;
  Company _selectedCompany;

  @override
  void initState() {
    _dropdownMenuItems = builDropdownMenuItems(_companies);
    _selectedCompany = _dropdownMenuItems[0].value;
    super.initState();
  }

  List<DropdownMenuItem<Company>> builDropdownMenuItems(List companies) {
    List<DropdownMenuItem<Company>> listItems = List();
    for (Company company in companies) {
      listItems.add(
        DropdownMenuItem(
          value: company,
          child: Text(
            company.name,
          ),
        ),
      );
    }
    return listItems;
  }

  onChangeDropDawn(Company selectedCompany) {
    setState(() {
      _selectedCompany = selectedCompany;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GradientBack(),
          bodyContainer(),
        ],
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

  dropDawnLocations() => DropdownButton(
        isExpanded: true,
        items: _dropdownMenuItems,
        value: _selectedCompany,
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

  inputUserName() => Container(
        padding: EdgeInsets.symmetric(vertical: 29.0),
        child: TextField(
          maxLines: 1,
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
          onPressed: () {},
        ),
      );

  loginButton() => Container(
        margin: EdgeInsets.only(top: 49),
        child: Material(
          child: InkWell(
            onTap: () => print('hello'),
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
                      onTap: () {},
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
                      onTap: () {},
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
}
