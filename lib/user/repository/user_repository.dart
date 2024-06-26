
import 'dart:io';

import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';


class UserRepository {

  final Firestore _db = Firestore.instance;
  final StorageReference _storageReference = FirebaseStorage.instance.ref();

  ///Get current user reference
  Future<DocumentReference> getCurrentUserReference() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return _db.collection(FirestoreCollections.users).document(user.uid);
  }

  Future<User> getCurrentUser() async {
    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      final querySnapshot = await _db
          .collection(FirestoreCollections.users)
          .where(FirestoreCollections.usersFieldUid, isEqualTo: user.uid)
          .getDocuments();
      if(querySnapshot.documents.length > 0) {
        return User.fromJson(querySnapshot.documents.first.data, id: querySnapshot.documents.first.documentID);
      } else {
        return null;
      }
    } catch (e) {
      print(e.message);
    }
  }

  Future<DocumentReference> getUserReferenceById(String userId) async {
    return _db.collection(FirestoreCollections.users).document(userId);
  }

  Future<DocumentReference> getUserReferenceByUserName(String userName) async {
    var querySnapshot = await _db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldName, isEqualTo: userName)
        .getDocuments();
    return querySnapshot.documents.first.reference;
  }

  Future<User> getUserById(String userId) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.users)
        .document(userId)
        .get();

    return User.fromJson(querySnapshot.data, id: querySnapshot.documentID);
  }

  void updateUserDataRepository(User user) async {
    DocumentReference ref = _db.collection(FirestoreCollections.users).document(user.id);
    return await ref.setData(user.toJson(), merge: true);
  }

  ///Get all users by id
  Stream<QuerySnapshot> getAllUsersStream() {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.users)
        .orderBy(FirestoreCollections.usersFieldName)
        .snapshots();
    return querySnapshot;
  }
  List<User> buildGetAllUsers(List<DocumentSnapshot> usersListSnapshot) {
    List<User> usersList = <User>[];
    usersListSnapshot.forEach((p) {
      User loc = User.fromJson(p.data, id: p.documentID);
      usersList.add(loc);
    });
    return usersList;
  }

  ///Get Users By Id
  Stream<QuerySnapshot> getUsersByIdStream(String uid) {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldUid, isEqualTo: uid)
        .snapshots();
    return querySnapshot;
  }
  User buildGetUsersById(List<DocumentSnapshot> usersListSnapshot) {
    return User.fromJson(usersListSnapshot.first.data, id: usersListSnapshot.first.documentID);
  }

  ///Search Users By Email
  Future<User> searchUserByEmail(String email) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldEmail, isEqualTo: email)
        .getDocuments();

    final documents = querySnapshot.documents;
    if (documents.length > 0) {
      final documentSnapshot = documents.first;
      return User.fromJson(
        documentSnapshot.data,
        id: documentSnapshot.documentID,
      );
    }
    return null;
  }

  /// Save user profile image in firebase storage
  Future<StorageTaskSnapshot> uploadProfileImageUser(
      String path, File imageFile) async {
    StorageUploadTask storageUploadTask = _storageReference.child(path).putData(
      imageFile.readAsBytesSync(),
      StorageMetadata(
        contentType: 'image/jpeg',
      ),
    );
    return storageUploadTask.onComplete;
  }

  /// Update email user
  Future<void> updateEmailUser(String email) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    user.updateEmail(email);
  }

  /// Update password user
  Future<void> updatePasswordUser(String password) async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    user.updatePassword(password);
  }

  /// Reset password user
  Future<void> resetPasswordUser(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

}