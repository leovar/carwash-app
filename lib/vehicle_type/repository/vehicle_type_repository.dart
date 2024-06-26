import 'package:car_wash_app/vehicle_type/model/brand.dart';
import 'package:car_wash_app/vehicle_type/model/brand_reference.dart';
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

  // Get Vehicle Brand References
  Stream<QuerySnapshot> getListBrandReferencesStream(String brandId) {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.brands)
        .document(brandId)
        .collection(FirestoreCollections.brandReferences)
        .snapshots();

    return querySnapshot;
  }
  List<BrandReference> buildBrandReferences(List<DocumentSnapshot> brandReferencesListSnapshot){
    List<BrandReference> brandReferencesList = <BrandReference>[];
    brandReferencesListSnapshot.forEach((p) {
      BrandReference bref = BrandReference.fromJson(p.data, id: p.documentID);
      brandReferencesList.add(bref);
    });
    return brandReferencesList;
  }

  // Save Brand Reference
  void updateBrandReference(String brandId, BrandReference product) async {
    DocumentReference ref =
    _db
        .collection(FirestoreCollections.brands)
        .document(brandId)
        .collection(FirestoreCollections.brandReferences)
        .document(product.id);
    return await ref.setData(product.toJson(), merge: true);
  }

  // Save Brand
  void updateBrand(Brand brand) async {
    DocumentReference ref =
    _db
        .collection(FirestoreCollections.brands)
        .document(brand.id);
    return await ref.setData(brand.toJson(), merge: true);
  }
}