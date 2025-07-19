import 'dart:async';
import 'dart:io';

import 'package:car_wash_app/user/model/sysUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Reference _storageReference = FirebaseStorage.instance.ref();

  ///Get current user reference
  Future<DocumentReference> getCurrentUserReference() async {
    User? user = FirebaseAuth.instance.currentUser;
    return _db.collection(FirestoreCollections.users).doc(user?.uid);
  }

  Future<SysUser?> getCurrentUser() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      final querySnapshot = await _db
          .collection(FirestoreCollections.users)
          .where(FirestoreCollections.usersFieldUid, isEqualTo: user?.uid)
          .get();
      if (querySnapshot.docs.length > 0) {
        return SysUser.fromJson(
            querySnapshot.docs.first.data(),
            id: querySnapshot.docs.first.id);
      } else {
        return Future.value(null);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<DocumentReference> getUserReferenceById(String userId) async {
    return _db.collection(FirestoreCollections.users).doc(userId);
  }

  Future<DocumentReference> getUserReferenceByUserName(String userName) async {
    var querySnapshot = await _db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldName, isEqualTo: userName)
        .get();
    return querySnapshot.docs.first.reference;
  }

  Future<SysUser> getUserById(String userId) async {
    final querySnapshot =
        await this._db.collection(FirestoreCollections.users).doc(userId).get();

    return SysUser.fromJson(querySnapshot.data() as Map<String, dynamic>,
        id: querySnapshot.id);
  }

  void updateUserDataRepository(SysUser userGet) async {
    DocumentReference ref =
        _db.collection(FirestoreCollections.users).doc(userGet.id);
    return await ref.set(userGet.toJson(), SetOptions(merge: true));
  }

  void updateUserCompanyDataRepository(SysUser userGet) async {
    DocumentReference ref =
    _db.collection(FirestoreCollections.users).doc(userGet.id);
    return await ref.set(userGet.toJsonUpdateCompany(), SetOptions(merge: true));
  }

  ///Get all users by id
  Stream<QuerySnapshot> getAllUsersStream(String companyId) {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldCompanyId, isEqualTo: companyId)
        .orderBy(FirestoreCollections.usersFieldName)
        .snapshots();
    return querySnapshot;
  }

  List<SysUser> buildGetAllUsers(List<DocumentSnapshot> usersListSnapshot) {
    List<SysUser> usersList = <SysUser>[];

    usersListSnapshot.forEach((p) {
      var data = p.data();
      if (data != null) {
        SysUser loc = SysUser.fromJson(p.data() as Map<String, dynamic>, id: p.id);
        usersList.add(loc);
      }
    });
    return usersList;
  }

  ///Get Users By Id
  Stream<QuerySnapshot<Map<String, dynamic>>> getUsersByIdStream(String uid) {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldUid, isEqualTo: uid)
        .snapshots();
    return querySnapshot;
  }

  SysUser buildGetUsersById(List<DocumentSnapshot> usersListSnapshot) {
    return SysUser.fromJson(
        usersListSnapshot.first.data() as Map<String, dynamic>,
        id: usersListSnapshot.first.id);
  }

  ///Search Users By Email
  Future<SysUser?> searchUserByEmail(String? email) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldEmail, isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return SysUser.fromJson(
          querySnapshot.docs.first.data(),
          id: querySnapshot.docs.first.id);
    }
    return Future.value(null);
  }

  //TODO validar si funciona la lo que hay en el putData
  /// Save user profile image in firebase storage
  Future<TaskSnapshot> uploadProfileImageUser(
      String path, File imageFile) async {
    Reference storageUploadTask = _storageReference.child(path);
    UploadTask uploadTask = storageUploadTask.putData(
      imageFile
          .readAsBytesSync(), // Esta es otra opcion que me da GPT: await imageFile.readAsBytes(),
      SettableMetadata(
        contentType: 'image/jpeg',
      ),
    );
    return await uploadTask;
  }

  /// Update email user
  Future<void> updateEmailUser(String email) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (email != null) {
      await user?.updateEmail(email);
    } else {
      throw Exception('El usuario no esta actualmente logueado');
    }
  }

  /// Update password user
  Future<void> updatePasswordUser(String password) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (password != null) {
    } else {
      throw new Exception('El usuario no esta actualmente logueado');
    }
    user?.updatePassword(password);
  }

  /// Reset password user
  Future<void> resetPasswordUser(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }
}
