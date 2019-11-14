import 'package:car_wash_app/vehicle_type/model/vehicleType.dart';
import 'package:car_wash_app/vehicle_type/repository/vehicle_type_repository.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class VehicleTypeBloc extends Bloc {

  final _vehicleTypeRepository = VehicleTypeRepository();

  Future<VehicleType> getVehicleTypeById(String idVehicleType) async {
    return await _vehicleTypeRepository.getVehicleTypeById(idVehicleType);
  }

  @override
  void dispose() {
  }

}