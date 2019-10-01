import 'package:car_wash_app/Usuario/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class UserBloc implements Bloc{

  final _auth_repository = AuthRepository();

  //Casos de uso del objeto User
  //1. Sign In con Google

  Future<FirebaseUser> signInGoogle() {
    return _auth_repository.signInFirebase();
  }

  Future<FirebaseUser> singnInFacebook() {
    return _auth_repository.signInFacebook();
  }

  @override
  void dispose() {
    // TODO: implement dispose
  }

}
