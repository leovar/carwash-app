import 'package:car_wash_app/vehicle/model/vehicle.dart';
import 'package:car_wash_app/vehicle/repository/vehicle_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class BlocVehicle extends Bloc {
  final _vehicleRepository = VehicleRepository();

  Future<Vehicle> getVehicleByPlaca(String placa) async {
    return await _vehicleRepository.getVehicleByPlaca(placa);
  }

  Future<DocumentReference> getVehicleReferenceByPlaca(String placa) async {
    return await _vehicleRepository.getVehicleReferenceByPlaca(placa);
  }

  Future<DocumentReference> updateVehicle(Vehicle vehicle) async {
    return await _vehicleRepository.updateVehicle(vehicle);
  }

  @override
  void dispose() {}
}
