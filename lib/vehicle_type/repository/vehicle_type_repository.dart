import 'package:car_wash_app/vehicle_type/model/vehicleType.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleTypeRepository {
  final Firestore _db = Firestore.instance;
  
  DocumentReference getVehicleTypeReferenceById (String idVehicleType){
    return _db.document('${FirestoreCollections.vehicleType}/$idVehicleType');
  }

  Stream<QuerySnapshot> getListVehicleTypesStream() {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.vehicleType)
        .snapshots();
    return querySnapshot;
  }
  List<VehicleType> buildVehicleType(List<DocumentSnapshot> productListSnapshot){
    List<VehicleType> vehicleTypeList = <VehicleType>[];
    productListSnapshot.forEach((p) {
      VehicleType loc = VehicleType.fromJson(p.data, id: p.documentID);
      vehicleTypeList.add(loc);
    });
    return vehicleTypeList;
  }

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

  Future<VehicleType> getVehicleTypeByUId(String uIdVehicleType) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.vehicleType)
        .where(FirestoreCollections.vehicleTypeFieldUid, isEqualTo: uIdVehicleType)
        .getDocuments();
    return VehicleType.fromJson(
      querySnapshot.documents.first.data,
      id: querySnapshot.documents.first.documentID,
    );
  }
}