import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthApi {
  final FirebaseAuth _authApi = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FacebookAuth _facebookSingIn = FacebookAuth.instance;

  //TODO recordar que esta fucnion en flutter 3 ya retorna un null, validar cuando es llamada como manejar este null
  //Authentication google
  Future<User?> signIn() async {
    //Inicio una instancia de la ventana de google por primera vez para loguearme con google
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;  // El usuario canceló el inicio de sesion

    //Obtengo las credenciales de google al autorizar el login con google
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    //Credenciales para Firebase
    final UserCredential _authResult = await _authApi.signInWithCredential(
        GoogleAuthProvider.credential(
            idToken: googleAuth.idToken, accessToken: googleAuth.accessToken));
    User? user = await _authResult.user;
    return user;
  }

  //Authentication Facebook
  //TODO el login con Facebook en IOS aun no funcion
  Future<User?> facebookSingIn() async {
    try {
      final LoginResult result = await _facebookSingIn.login(permissions: ['email', 'public_profile']);

      switch (result.status) {
        case LoginStatus.success:
          final AccessToken accessToken = result.accessToken!;
          print("""Login Satisfactorio 
            Token: ${accessToken.tokenString}""");

          UserCredential authResult = await _authApi.signInWithCredential(
            FacebookAuthProvider.credential(accessToken.tokenString),
          );
          User? user = authResult.user;
          return user;
          break;
        case LoginStatus.cancelled:
          print("Login Cancelado");
          return null;
          break;
        case LoginStatus.failed:
          print("Error en login ${result.message}");
          return null;
          break;
        default:
          return null;
          break;
      }
    } catch (error) {
      print("Error general en login ${error}");
      return null;
    }
  }

  //Authentication Email
  Future<User?> emailAndPasswordSignIn(String email, String password) async {
    try {
      UserCredential authResult = await _authApi.signInWithEmailAndPassword(
          email: email, password: password);

      User? user = authResult.user;
      return user;
    } catch (e) {
      print("Error in email and password sign-in: $e");
      return null;
    }
  }

  Future<String> registerEmailUser(String email, String password) async {
    try {
      FirebaseApp secondApp = await Firebase.initializeApp(
        name: 'CarwachApp',
        options: const FirebaseOptions(
          apiKey: 'AIzaSyCZZfdnJ3eEZ9RIMuQtQYDABArHjTSjFxY',
          appId: 'carwash-app-9a2c2',
          messagingSenderId: '282309180715',
          projectId: 'carwash-app-9a2c2',
          databaseURL:'https://carwash-app-9a2c2.firebaseio.com',
        )
      );

      // Get FirebaseAuth instance for the second app
      FirebaseAuth secondAuth = FirebaseAuth.instanceFor(app: secondApp);

      // Create a user with email and password
      UserCredential authResult = await secondAuth.createUserWithEmailAndPassword(email: email, password: password);

      String userUid = authResult.user!.uid;

      // Sign out from the second instance
      await secondAuth.signOut();
      return userUid;
    } catch (e) {
      print("Error in email registration: $e");
      return '';
    }
  }

  void resetEmailPassword(String email) async {
    _authApi.sendPasswordResetEmail(email: email);
  }

  singOut() async {
    await _authApi.signOut();
    await _googleSignIn.signOut();
    await _facebookSingIn.logOut();
  }
}
