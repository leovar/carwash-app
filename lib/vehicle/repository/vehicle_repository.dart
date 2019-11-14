import 'package:car_wash_app/vehicle/model/vehicle.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleRepository {
  final Firestore _db = Firestore.instance;

  Future<Vehicle> getVehicleByPlaca(String placa) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.vehicles)
        .where(FirestoreCollections.vehiclesFieldPlaca, isEqualTo: placa)
        .getDocuments();

    final documents = querySnapshot.documents;
    if (documents.length > 0) {
      final documentSnapshot = documents.first;
      return Vehicle.fromJson(
        documentSnapshot.data,
        id: documentSnapshot.documentID,
      );
    }
    return null;
  }

  Future<DocumentReference> getVehicleReferenceByPlaca(String placa) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.vehicles)
        .where(FirestoreCollections.vehiclesFieldPlaca, isEqualTo: placa)
        .getDocuments();

    final documents = querySnapshot.documents;
    if (documents.length > 0) {
      return documents.first.reference;
    }
    return null;
  }

  Future<Vehicle> getVehicleById(String idVehicle) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.vehicles)
        .document(idVehicle)
        .get();
    return Vehicle.fromJson(
      querySnapshot.data,
      id: querySnapshot.documentID,
    );
  }

  Future<DocumentReference> updateVehicle(Vehicle vehicle) async {
    DocumentReference ref =
        _db.collection(FirestoreCollections.vehicles).document(vehicle.id);
    ref.setData(vehicle.toJson(), merge: true);
    return ref;
  }
}
