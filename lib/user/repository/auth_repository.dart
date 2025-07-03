import 'package:car_wash_app/user/repository/firebase_auth_api.dart';
import 'package:firebase_auth/firebase_auth.dart';

//En esta clase se manejan los diferentes tipos de autenticación
class AuthRepository {

  final _firebaseAuthApi = FirebaseAuthApi();

  Future<User?> signInFirebase() => _firebaseAuthApi.signIn();

  Future<User?> signInFacebook() => _firebaseAuthApi.facebookSingIn();

  Future<User?> signInEmail(String email, String password) {
    return _firebaseAuthApi.emailAndPasswordSignIn(email, password);
  }

  Future<String> registerEmailUser(String email, String password) {
    return _firebaseAuthApi.registerEmailUser(email, password);
  }

  singOut() => _firebaseAuthApi.singOut();

}