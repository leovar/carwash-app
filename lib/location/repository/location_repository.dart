import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DocumentReference> updateLocationDataRepository(Location location) async {
    DocumentReference ref = _db.collection(FirestoreCollections.locations).doc(location.id);
    ref.set(location.toJson(), SetOptions(merge: true));
    return ref;
  }

  DocumentReference getDocumentReferenceLocationById(String idLocation) {
    return _db.doc('${FirestoreCollections.locations}/$idLocation');
  }

  Future<DocumentReference> getLocationReference(String locationId) async {
    return _db.collection(FirestoreCollections.locations).doc(locationId);
  }

  Stream<QuerySnapshot> getLocationsStream() {
    var querySnapshot = this
        ._db
        .collection(FirestoreCollections.locations)
        .snapshots();
    return querySnapshot;
  }

  List<Location> buildLocations(List<DocumentSnapshot> placesListSnapshot){
    List<Location> locationsList = [];
    placesListSnapshot.forEach((p) {
      var data = p.data();
      if (data != null) {
        Location loc = Location.fromJson(data as Map<String, dynamic>, id: p.id);
        locationsList.add(loc);
      }
    });
    return locationsList;
  }

  ///Get all locations

  Future<Location> getLocationById(String locationId) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.locations)
        .doc(locationId)
        .get();

    return Location.fromJson(querySnapshot.data() as Map<String, dynamic>, id: querySnapshot.id);
  }

  Stream<QuerySnapshot> getAllLocationsStream() {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.locations)
        .snapshots();
    return querySnapshot;
  }
  List<Location> buildGetAllLocations(List<DocumentSnapshot> locationsListSnapshot) {
    List<Location> locationsList = <Location>[];
    locationsListSnapshot.forEach((p) {
      Location loc = Location.fromJson(p.data() as Map<String, dynamic>, id: p.id);
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
      .get();

    result.docs.forEach((f) {
      Location loc = Location.fromJson(f.data(), id: f.id);
      locList.add(loc);
    });
    return locList;
  }

}
