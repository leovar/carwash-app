
import 'package:car_wash_app/user/repository/auth_repository.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/location/repository/location_repository.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/user/repository/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class UserBloc implements Bloc {
  final _auth_repository = AuthRepository();
  final _userRepository = UserRepository();

  //Casos de uso del objeto User
  //1. Sign In con Google
  //2. Sign In con Facebook
  //3. Sign Out
  //4. Registrar usuario en la base de datos

  //stream Controller
  Stream<FirebaseUser> streamFirebase = FirebaseAuth.instance.onAuthStateChanged;
  Stream<FirebaseUser> get authStatus => streamFirebase;

  Future<FirebaseUser> signInGoogle() {
    return _auth_repository.signInFirebase();
  }

  Future<FirebaseUser> singnInFacebook() {
    return _auth_repository.signInFacebook();
  }

  singOut() {
    return _auth_repository.singOut();
  }

  void updateUserData(User user) async {
    _userRepository.updateUserDataRepository(user);
  }

  Future<User> searchUserByEmail(String email) async {
    return await _userRepository.searchUserByEmail(email);
  }


  @override
  void dispose() {
    // TODO: implement dispose
  }
}