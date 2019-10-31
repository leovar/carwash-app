import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationRepository {
  final Firestore _db = Firestore.instance;

  Future<DocumentReference> getLocationReference(String locationId) async {
    return _db.collection(FirestoreCollections.locations).document(locationId);
  }

  Stream<QuerySnapshot> getLocationsStream() {
    var querySnapshot = this
        ._db
        .collection(FirestoreCollections.locations)
        .snapshots();
    return querySnapshot;
  }

  List<Location> buildLocations(List<DocumentSnapshot> placesListSnapshot){
    List<Location> locationsList = List<Location>();
    placesListSnapshot.forEach((p) {
      Location loc = Location.fromJson(p.data, id: p.documentID);
      locationsList.add(loc);
    });
    return locationsList;
  }

  ///Este Metodo retorna la lista de locaciones (aun no usado de esta manera), al igual que el metodo anterior buildLocations
  ///el metodo anterior retornan la misma lista pero por medio de steamBuider
  Future<List<Location>> getLocations() async {
    List<Location> locList = <Location>[];
    final result = await this
      ._db
      .collection(FirestoreCollections.locations)
      .getDocuments();

    result.documents.forEach((f) {
      Location loc = Location.fromJson(f.data, id: f.documentID);
      locList.add(loc);
    });
    return locList;
  }

}
