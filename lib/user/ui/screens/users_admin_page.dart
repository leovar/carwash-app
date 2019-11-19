import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class UsersAdminPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _UsersAdminPage();
}

class _UsersAdminPage extends State<UsersAdminPage> {
  UserBloc _userBloc;

  @override
  Widget build(BuildContext context) {
    _userBloc = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Usuarios",
          style: TextStyle(
            fontFamily: "Lato",
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _bodyContainer(),
      ),
    );
  }

  Widget _bodyContainer() {
    return Container(

    );
  }
}