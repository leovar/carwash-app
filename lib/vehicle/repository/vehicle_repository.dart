import 'dart:ffi';

import 'package:car_wash_app/vehicle/model/vehicle.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Vehicle?> getVehicleByPlaca(String placa) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.vehicles)
        .where(FirestoreCollections.vehiclesFieldPlaca, isEqualTo: placa)
        .get();

    final documents = querySnapshot.docs;
    if (documents.length > 0) {
      final documentSnapshot = documents.first;
      return Vehicle.fromJson(
        documentSnapshot.data as Map<String, dynamic>,
        id: documentSnapshot.id,
      );
    }
    return null;
  }

  Future<DocumentReference?> getVehicleReferenceByPlaca(String placa) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.vehicles)
        .where(FirestoreCollections.vehiclesFieldPlaca, isEqualTo: placa)
        .get();

    final documents = querySnapshot.docs;
    if (documents.length > 0) {
      return documents.first.reference;
    }
    return null;
  }

  Future<Vehicle> getVehicleById(String idVehicle) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.vehicles)
        .doc(idVehicle)
        .get();
    return Vehicle.fromJson(
      querySnapshot.data as Map<String, dynamic>,
      id: querySnapshot.id,
    );
  }

  Future<DocumentReference> updateVehicle(Vehicle vehicle) async {
    DocumentReference ref =
        _db.collection(FirestoreCollections.vehicles).doc(vehicle.id);
    ref.set(vehicle.toJson(), SetOptions(merge: true));
    return ref;
  }
}
