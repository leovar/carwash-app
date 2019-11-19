import 'package:car_wash_app/vehicle_type/model/vehicleType.dart';
import 'package:car_wash_app/vehicle_type/repository/vehicle_type_repository.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class VehicleTypeBloc extends Bloc {

  final _vehicleTypeRepository = VehicleTypeRepository();

  Stream<QuerySnapshot> get vehicleTypeStream => _vehicleTypeRepository.getListVehicleTypesStream();
  List<VehicleType> buildVehicleType(List<DocumentSnapshot> vehicleTypeListSnapshot) => _vehicleTypeRepository.buildVehicleType(vehicleTypeListSnapshot);


  Future<VehicleType> getVehicleTypeById(String idVehicleType) async {
    return await _vehicleTypeRepository.getVehicleTypeById(idVehicleType);
  }

  Future<VehicleType> getVehicleTypeByUId(String uidVehicleType) async {
    return await _vehicleTypeRepository.getVehicleTypeByUId(uidVehicleType);
  }

  DocumentReference getVehicleTypeReferenceById(String idVehicleType) => _vehicleTypeRepository.getVehicleTypeReferenceById(idVehicleType);

  @override
  void dispose() {
  }

}