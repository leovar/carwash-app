
import 'dart:io';

import 'package:car_wash_app/user/repository/auth_repository.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/location/repository/location_repository.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/user/repository/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:path/path.dart';

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

  Future<FirebaseUser> signInFacebook() {
    return _auth_repository.signInFacebook();
  }

  Future<FirebaseUser> signInEmail(String email, String password) {
    return _auth_repository.signInEmail(email, password);
  }

  singOut() {
    return _auth_repository.singOut();
  }

  Future<String> registerEmailUser(String email, String password) {
    return _auth_repository.registerEmailUser(email, password);
  }

  Future<void> updateUserData(User user) async {

    if (user.photoUrl.isNotEmpty && !user.photoUrl.contains('https://')) {
      File imageFile = File(user.photoUrl);
      final pathImage = '${user.id}/profile/${basename(user.photoUrl)}';
      StorageTaskSnapshot storageTaskSnapshot = await _userRepository.uploadProfileImageUser(pathImage, imageFile);
      String imageUrl = await storageTaskSnapshot.ref.getDownloadURL();
      user.photoUrl = imageUrl;
    }
    _userRepository.updateUserDataRepository(user);
  }

  Future<User> getUserById(String userId) async => await _userRepository.getUserById(userId);

  Future<DocumentReference> getCurrentUserReference() async {
    return _userRepository.getCurrentUserReference();
  }

  Future<User> getCurrentUser() async {
    return await _userRepository.getCurrentUser();
  }

  Future<DocumentReference> getUserReferenceById(String userId) async {
    return _userRepository.getUserReferenceById(userId);
  }

  Future<DocumentReference> getUserReferenceByUserName(String userName) async {
    return _userRepository.getUserReferenceByUserName(userName);
  }

  Stream<QuerySnapshot> getUsersByIdStream(String uid) {
    return _userRepository.getUsersByIdStream(uid);
  }
  User buildUsersById(List<DocumentSnapshot> usersListSnapshot) => _userRepository.buildGetUsersById(usersListSnapshot);

  Stream<QuerySnapshot> get allUsersStream => _userRepository.getAllUsersStream();
  List<User> buildAllUsers(List<DocumentSnapshot> usersListSnapshot) => _userRepository.buildGetAllUsers(usersListSnapshot);

  Future<User> searchUserByEmail(String email) async {
    return await _userRepository.searchUserByEmail(email);
  }



  @override
  void dispose() {
  }
}