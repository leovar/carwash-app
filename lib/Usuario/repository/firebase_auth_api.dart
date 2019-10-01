import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthApi {
  final FirebaseAuth _authApi = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FacebookLogin _facebookSingIn = FacebookLogin();

  //Autenticasion con google
  //TODO el login con
  Future<FirebaseUser> signIn() async {
    //Inicio una instancia de la ventana de google por primera vez para loguearme con google
    GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication gSA = await googleSignInAccount
        .authentication; //Obtengo las credenciales de google al autorizar el login con google

    //Autenticacion con Firebase
    AuthResult _authResult = await _authApi.signInWithCredential(
        GoogleAuthProvider.getCredential(
            idToken: gSA.idToken, accessToken: gSA.accessToken));
    FirebaseUser user = await _authResult.user;

    return user;
  }

  //Autenticasion con Facebook
  //TODO el login con Facebook en IOS aun no funcion
  Future<FirebaseUser> facebookSingIn() async {
    final FacebookLoginResult result =
        await _facebookSingIn.logIn(['email', 'public_profile']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final FacebookAccessToken accessToken = result.accessToken;
        print("""Login Satisfactorio 
            Token: ${accessToken.token}
            User id: ${accessToken.userId}
            Expires: ${accessToken.expires}
            Permissions: ${accessToken.permissions}
            Declined permissions: ${accessToken.declinedPermissions}""");
        AuthResult authResult = await _authApi.signInWithCredential(
            FacebookAuthProvider.getCredential(accessToken: accessToken.token));
        FirebaseUser user = authResult.user;
        return user;
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("Login Cancelado");
        return null;
        break;
      case FacebookLoginStatus.error:
        print("Error en login ${result.errorMessage}");
        return null;
        break;
      default:
        return null;
        break;
    }
  }

  //Autenticacion con Email
  //TODO esta funcion aun no se ha probado
  Future<FirebaseUser> emailAndPasswordSignIn(
      String email, String password) async {
    AuthResult authResult = await _authApi.signInWithEmailAndPassword(
        email: email, password: password);

    FirebaseUser user = authResult.user;

    return user;
  }
}
