import 'dart:async';
import 'package:car_wash_app/User/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'User/ui/screens/login_page.dart';
import 'User/bloc/bloc_user.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: UserBloc(),
      child: MaterialApp(
        title: 'Carwash Movil App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          secondaryHeaderColor: Color(0xFF27AEBB),
          primaryColor: Color(0xFF27AEBB),
        ),
        home: LoginPage(),
        //HomePage(),//LoginPage(),
        initialRoute: 'main',
        routes: {
          'main': (context) => LoginPage(),
        },
      ),
    );
  }
}
