import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:car_wash_app/User/model/user.dart';

class CloudFirestoreApi {

  final String USERS = "users";
  final String SALES = "sales";
  final String CUSTOMERS = "customers";
  final String SERVICES = "services";


  final Firestore _db = Firestore.instance;

  void updateUserData(User user) async {
    DocumentReference ref = _db.collection(USERS).document(user.uid);
    return ref.setData({
      'uid': user.uid,
      'name': user.name,
      'email' : user.email,
      'photoUrl' : user.photoUrl,
      'lastSignIn' : DateTime.now()
    }, merge: true);
  }
}