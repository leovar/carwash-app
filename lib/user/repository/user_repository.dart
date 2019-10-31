
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UserRepository {

  final Firestore _db = Firestore.instance;

  ///Get current user reference
  Future<DocumentReference> getUserReference() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return _db.collection(FirestoreCollections.users).document(user.uid);
  }

  Future<DocumentReference> getUserReferenceById(String userId) async {
    return _db.collection(FirestoreCollections.users).document(userId);
  }

  void updateUserDataRepository(User user) async {
    DocumentReference ref = _db.collection(FirestoreCollections.users).document(user.uid);
    return await ref.setData(user.toJson(), merge: true);
  }

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

}