
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';


class UserRepository {

  final Firestore _db = Firestore.instance;

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