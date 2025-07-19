import 'dart:io';

import 'package:car_wash_app/user/repository/auth_repository.dart';
import 'package:car_wash_app/user/model/sysUser.dart';
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
  Stream<User?> streamFirebase = FirebaseAuth.instance.authStateChanges();
  Stream<User?> get authStatus => streamFirebase;

  Future<User?> signInGoogle() {
    return _auth_repository.signInFirebase();
  }

  Future<User?> signInFacebook() {
    return _auth_repository.signInFacebook();
  }

  Future<User?> signInEmail(String email, String password) {
    return _auth_repository.signInEmail(email, password);
  }

  singOut() async {
    return await _auth_repository.singOut();
  }

  Future<String> registerEmailUser(String email, String password) {
    return _auth_repository.registerEmailUser(email, password);
  }

  Future<void> updateUserData(SysUser user) async {
    if (user.photoUrl!.isNotEmpty && !user.photoUrl!.contains('https://')) {
      File imageFile = File(user.photoUrl!);
      final pathImage = '${user.id}/profile/${basename(user.photoUrl!)}';
      TaskSnapshot storageTaskSnapshot =
          await _userRepository.uploadProfileImageUser(pathImage, imageFile);
      String imageUrl = await storageTaskSnapshot.ref.getDownloadURL();
      user.photoUrl = imageUrl;
    }
    _userRepository.updateUserDataRepository(user);
  }

  Future<void> updateUserCompany(SysUser user) async {
    _userRepository.updateUserCompanyDataRepository(user);
  }

  Future<void> updateEmailUser(String email) async {
    return await _userRepository.updateEmailUser(email);
  }

  Future<void> updatePasswordUser(String password) async {
    return await _userRepository.updatePasswordUser(password);
  }

  Future<void> resetPasswordUser(String email) async {
    return await _userRepository.resetPasswordUser(email);
  }

  Future<SysUser> getUserById(String userId) async =>
      await _userRepository.getUserById(userId);

  Future<DocumentReference> getCurrentUserReference() async {
    return _userRepository.getCurrentUserReference();
  }

  Future<SysUser?> getCurrentUser() async {
    return await _userRepository.getCurrentUser();
  }

  Future<DocumentReference> getUserReferenceById(String userId) async {
    return _userRepository.getUserReferenceById(userId);
  }

  Future<DocumentReference> getUserReferenceByUserName(String userName) async {
    return _userRepository.getUserReferenceByUserName(userName);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUsersByIdStream(String uid) {
    return _userRepository.getUsersByIdStream(uid);
  }

  SysUser buildUsersById(List<DocumentSnapshot> usersListSnapshot) =>
      _userRepository.buildGetUsersById(usersListSnapshot);

  Stream<QuerySnapshot> allUsersStream(String companyId) {
    return _userRepository.getAllUsersStream(companyId);
  }

  List<SysUser> buildAllUsers(List<DocumentSnapshot> usersListSnapshot) =>
      _userRepository.buildGetAllUsers(usersListSnapshot);

  Future<SysUser?> searchUserByEmail(String? email) async {
    return await _userRepository.searchUserByEmail(email);
  }

  @override
  void dispose() {}
}
