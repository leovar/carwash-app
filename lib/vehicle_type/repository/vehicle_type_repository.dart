import 'package:car_wash_app/vehicle_type/model/vehicleType.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleTypeRepository {
  final Firestore _db = Firestore.instance;


  Future<VehicleType> getVehicleTypeById(String idVehicleType) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.vehicleType)
        .document(idVehicleType)
        .get();
    return VehicleType.fromJson(
      querySnapshot.data,
      id: querySnapshot.documentID,
    );
  }
}