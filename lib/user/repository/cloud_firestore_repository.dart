import 'package:car_wash_app/User/model/user.dart';
import 'package:car_wash_app/User/repository/cloud_firestore_api_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class CloudFirestoreRepository {

  final _cloudFirestoreApi = CloudFirestoreApi();

  void updateUserDataReposiroty(User user) => _cloudFirestoreApi.updateUserData(user);

}