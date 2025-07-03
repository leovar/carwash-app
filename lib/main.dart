import 'package:car_wash_app/firebase_options.dart';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'user/ui/screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( // Initialize Firebase
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.light),
  );
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
          secondaryHeaderColor: Color(0xFF27AEBB),
          primaryColor: Color(0xFF27AEBB),
          cardColor: Color(0xFF787A71),
          dividerColor: Color(0xFFF1F1F1),
          textTheme: TextTheme(
            labelLarge: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 19,
            ),
            headlineMedium: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 19,
            ),
            displaySmall: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              color: Colors.black,
              fontSize: 17,
            )
          ), textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xFFAEAEAE)), colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(secondary: Color(0xFF59B258)).copyWith(error: Color(0xFFAF5048)),
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
