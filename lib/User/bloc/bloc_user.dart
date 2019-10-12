import 'package:car_wash_app/User/model/user.dart';
import 'package:car_wash_app/User/repository/auth_repository.dart';
import 'package:car_wash_app/User/repository/cloud_firestore_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class UserBloc implements Bloc {
  final _auth_repository = AuthRepository();

  //Casos de uso del objeto User
  //1. Sign In con Google
  //2. Sign In con Facebook
  //3. Sign Out
  //4. Registrar usuario en la base de datos

  //stream Controller
  Stream<FirebaseUser> streamFirebase = FirebaseAuth.instance.onAuthStateChanged;
  Stream<FirebaseUser> get authStatus => streamFirebase;

  final _cloudFirestoreRepository = CloudFirestoreRepository();

  Future<FirebaseUser> signInGoogle() {
    return _auth_repository.signInFirebase();
  }

  Future<FirebaseUser> singnInFacebook() {
    return _auth_repository.signInFacebook();
  }

  singOut() {
    return _auth_repository.singOut();
  }

  void updateUserData(User user) => _cloudFirestoreRepository.updateUserDataReposiroty(user);



  @override
  void dispose() {
    // TODO: implement dispose
  }
}