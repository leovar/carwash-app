import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'Autenticacion/ui/screens/login_page.dart';
import 'Home/ui/screens/home_page.dart';
import 'Factura/ui/screens/factura_page.dart';
import 'Autenticacion/bloc/bloc_autenticacion.dart';

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
      bloc: AutenticacionBloc(),
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
          'main': (context) => HomePage(),
        },
      ),
    );
  }
}
