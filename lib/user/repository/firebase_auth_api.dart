import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthApi {
  final FirebaseAuth _authApi = FirebaseAuth.instance;
  final FacebookAuth _facebookSingIn = FacebookAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;

  Future<void> _initGoogleSignIn() async {
    if (!_googleInitialized) {
      await _googleSignIn.initialize(
        clientId: 'TU_CLIENT_ID_IOS.apps.googleusercontent.com',
        serverClientId: 'TU_CLIENT_ID_SERVIDOR.apps.googleusercontent.com',
      );
      _googleInitialized = true;
    }
  }

  // Authentication Google
  Future<User?> signIn() async {
    await _initGoogleSignIn();

    try {
      final GoogleSignInAccount account = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'],
      );
      final auth = account.authentication;
      final cred = GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: auth.accessToken,
      );
      final result = await _authApi.signInWithCredential(cred);
      return result.user;
    } on GoogleSignInException catch (e) {
      print('Google SignIn error: ${e.code.name} — ${e.description}');
      return null;
    } catch (e) {
      print('Unexpected Google SignIn error: $e');
      return null;
    }
  }

  // Authentication Facebook
  // TODO el login con Facebook en IOS aun no funciona
  Future<User?> facebookSingIn() async {
    try {
      final LoginResult result =
      await _facebookSingIn.login(permissions: ['email', 'public_profile']);

      switch (result.status) {
        case LoginStatus.success:
          final AccessToken accessToken = result.accessToken!;
          print("""Login Satisfactorio \\n            Token: ${accessToken.tokenString}""");

          UserCredential authResult = await _authApi.signInWithCredential(
            FacebookAuthProvider.credential(accessToken.tokenString),
          );
          User? user = authResult.user;
          return user;
        case LoginStatus.cancelled:
          print("Login Cancelado");
          return null;
        case LoginStatus.failed:
          print("Error en login ${result.message}");
          return null;
        default:
          return null;
      }
    } catch (error) {
      print("Error general en login ${error}");
      return null;
    }
  }

  // Authentication Email
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
          databaseURL: 'https://carwash-app-9a2c2.firebaseio.com',
        ),
      );

      FirebaseAuth secondAuth = FirebaseAuth.instanceFor(app: secondApp);

      UserCredential authResult = await secondAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      String userUid = authResult.user!.uid;
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
    await _googleSignIn.disconnect();
    await _facebookSingIn.logOut();
  }
}
