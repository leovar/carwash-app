import 'dart:core' as prefix0;
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../widgets/gradient_back.dart';
import '../widgets/header_login.dart';

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

  Company(this.Id, this.name);

  static List<Company> getCompanies() {
    return <Company>[
      Company(1, 'Molinos'),
      Company(1, 'Palmas'),
      Company(1, 'La Ceja'),
      Company(1, 'La Central'),
    ];
  }
}

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
          child: Text(company.name),
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

  bodyContainer() =>
      Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              HeaderLogin(),
              SizedBox(
                height: 53.0,
              ),
              inputData(),
            ],
          ),
        ),
      );

  inputData() => Container(
    margin: EdgeInsets.only(top: 53, left: 52, right: 52,),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        dropDawnLocations()
      ],
    ),
  );

  dropDawnLocations() => DropdownButton(
    isExpanded: true,
    value: _selectedCompany,
    items: _dropdownMenuItems,
    onChanged: onChangeDropDawn,
    hint: Text("Sede"),
  );
}
