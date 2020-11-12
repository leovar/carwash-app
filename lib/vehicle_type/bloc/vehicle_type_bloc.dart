import 'package:car_wash_app/vehicle_type/model/brand.dart';
import 'package:car_wash_app/vehicle_type/model/brand_reference.dart';
import 'package:car_wash_app/vehicle_type/model/vehicleType.dart';
import 'package:car_wash_app/vehicle_type/repository/vehicle_type_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class VehicleTypeBloc extends Bloc {
  final _vehicleTypeRepository = VehicleTypeRepository();

  Stream<QuerySnapshot> get vehicleTypeStream =>
      _vehicleTypeRepository.getListVehicleTypesStream();

  List<VehicleType> buildVehicleType(
          List<DocumentSnapshot> vehicleTypeListSnapshot) =>
      _vehicleTypeRepository.buildVehicleType(vehicleTypeListSnapshot);

  Future<VehicleType> getVehicleTypeById(String idVehicleType) async {
    return await _vehicleTypeRepository.getVehicleTypeById(idVehicleType);
  }

  Future<VehicleType> getVehicleTypeByUId(String uidVehicleType) async {
    return await _vehicleTypeRepository.getVehicleTypeByUId(uidVehicleType);
  }

  DocumentReference getVehicleTypeReferenceById(String idVehicleType) =>
      _vehicleTypeRepository.getVehicleTypeReferenceById(idVehicleType);

  //Get Brand Reference
  Stream<QuerySnapshot> vehicleBrandReferences(String brandId) =>
      _vehicleTypeRepository.getListBrandReferencesStream(brandId);

  List<BrandReference> buildBrandReference(
          List<DocumentSnapshot> brandRefSnapshot) =>
      _vehicleTypeRepository.buildBrandReferences(brandRefSnapshot);

  void updateBrandReference(
      String brandId, BrandReference brandReference) async {
    return _vehicleTypeRepository.updateBrandReference(brandId, brandReference);
  }

  void updateBrand(Brand brand) async {
    return _vehicleTypeRepository.updateBrand(brand);
  }

  @override
  void dispose() {}
}
