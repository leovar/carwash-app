import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/user/ui/screens/create_user_admin_page.dart';
import 'package:car_wash_app/user/ui/screens/login_page.dart';
import 'package:car_wash_app/user/ui/widgets/item_user_admin_list.dart';
import 'package:car_wash_app/widgets/home_page.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class UsersAdminPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _UsersAdminPage();
}

class _UsersAdminPage extends State<UsersAdminPage> {
  UserBloc _userBloc;
  List<User> _userList = <User>[];

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
      padding: EdgeInsets.only(bottom: 17),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _listUsersStream(),
          _buttonNewUser(),
        ],
      ),
    );
  }

  Widget _listUsersStream() {
    return StreamBuilder(
      stream: _userBloc.allUsersStream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return _getDataUsersList(snapshot);
        }
      },
    );
  }
  Widget _getDataUsersList(AsyncSnapshot snapshot) {
    _userList = _userBloc.buildAllUsers(snapshot.data.documents);
    return Flexible(
      child: ListView.builder(
        itemCount: _userList.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return ItemUserAdminList(_userList, index);
        },
      ),
    );
  }

  Widget _buttonNewUser() {
    return Container(
      height: 60,
      margin: EdgeInsets.only(top: 8,),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
          color: Color(0xFF59B258),
          child: Text(
            "Nuevo Usuario",
            style: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 19,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return BlocProvider(
                    bloc: UserBloc(),
                    child: CreateUserAdminPage(),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}