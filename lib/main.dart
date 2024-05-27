import 'dart:async';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'user/ui/screens/login_page.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light),
  );
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      bloc: UserBloc(),
      child: MaterialApp(
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en'), // English
          const Locale('es'), // Hebrew
          const Locale.fromSubtags(languageCode: 'en'), // Chinese *See Advanced Locales below*
          // ... other locales the app supports
        ],
        debugShowCheckedModeBanner: false,
        title: 'Carwash Movil App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          secondaryHeaderColor: Color(0xFF27AEBB),
          primaryColor: Color(0xFF27AEBB),
          accentColor: Color(0xFF59B258),
          cardColor: Color(0xFF787A71),
          cursorColor: Color(0xFFAEAEAE),
          dividerColor: Color(0xFFF1F1F1),
          errorColor: Color(0xFFAF5048),
          textTheme: TextTheme(
            button: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 19,
            ),
            display1: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 19,
            ),
            display2: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              color: Colors.black,
              fontSize: 17,
            )
          ),
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
