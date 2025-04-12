import 'package:car_wash_app/vehicle_type/model/brand.dart';
import 'package:car_wash_app/vehicle_type/model/brand_reference.dart';
import 'package:car_wash_app/vehicle_type/model/vehicleType.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleTypeRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  DocumentReference getVehicleTypeReferenceById (String idVehicleType){
    return _db.doc('${FirestoreCollections.vehicleType}/$idVehicleType');
  }

  Stream<QuerySnapshot> getListVehicleTypesStream() {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.vehicleType)
        .snapshots();
    return querySnapshot;
  }
  List<VehicleType> buildVehicleType(List<DocumentSnapshot> productListSnapshot) {
    List<VehicleType> vehicleTypeList = <VehicleType>[];
    productListSnapshot.forEach((p) {
      VehicleType loc = VehicleType.fromJson(p.data() as Map<String, dynamic>, id: p.id);
      vehicleTypeList.add(loc);
    });
    return vehicleTypeList;
  }

  Future<VehicleType> getVehicleTypeById(String idVehicleType) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.vehicleType)
        .doc(idVehicleType)
        .get();
    return VehicleType.fromJson(
      querySnapshot.data() as Map<String, dynamic>,
      id: querySnapshot.id,
    );
  }

  Future<VehicleType> getVehicleTypeByUId(String uIdVehicleType) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.vehicleType)
        .where(FirestoreCollections.vehicleTypeFieldUid, isEqualTo: uIdVehicleType)
        .get();
    return VehicleType.fromJson(
      querySnapshot.docs.first.data(),
      id: querySnapshot.docs.first.id,
    );
  }

  // Get Vehicle Brand References
  Stream<QuerySnapshot> getListBrandReferencesStream(String brandId) {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.brands)
        .doc(brandId)
        .collection(FirestoreCollections.brandReferences)
        .snapshots();

    return querySnapshot;
  }
  List<BrandReference> buildBrandReferences(List<DocumentSnapshot> brandReferencesListSnapshot){
    List<BrandReference> brandReferencesList = <BrandReference>[];
    brandReferencesListSnapshot.forEach((p) {
      BrandReference bref = BrandReference.fromJson(p.data() as Map<String, dynamic>, id: p.id);
      brandReferencesList.add(bref);
    });
    return brandReferencesList;
  }

  // Save Brand Reference
  void updateBrandReference(String brandId, BrandReference product) async {
    DocumentReference ref =
    _db
        .collection(FirestoreCollections.brands)
        .doc(brandId)
        .collection(FirestoreCollections.brandReferences)
        .doc(product.id);
    return await ref.set(product.toJson(), SetOptions(merge: true));
  }

  // Save Brand
  void updateBrand(Brand brand) async {
    DocumentReference ref =
    _db
        .collection(FirestoreCollections.brands)
        .doc(brand.id);
    return await ref.set(brand.toJson(), SetOptions(merge: true));
  }
}