import 'package:car_wash_app/Usuario/repository/firebase_auth_api.dart';
import 'package:firebase_auth/firebase_auth.dart';

//En esta clase se manejan los diferentes tipos de autenticación
class AuthRepository {

  final _firebaseAuthApi = FirebaseAuthApi();

  Future<FirebaseUser> signInFirebase() => _firebaseAuthApi.signIn();

  Future<FirebaseUser> signInFacebook() => _firebaseAuthApi.facebookSingIn();

  singOut() => _firebaseAuthApi.singOut();

}