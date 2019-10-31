import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/customer/repository/customer_repository.dart';
import 'package:car_wash_app/vehicle/bloc/bloc_vehicle.dart';
import 'package:car_wash_app/vehicle/model/vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class BlocCustomer implements Bloc {

  final _customerRepository = CustomerRepository();
  final _blocVehicle = BlocVehicle();

  //Casos de uso
  //1. Obtener Customer por Placa

  Future<Customer> getCustomerByVehicle(String placa) async {
    await _blocVehicle.getVehicleByPlaca(placa).then((Vehicle vehicle) {
      if (vehicle != null) {
          _customerRepository.getCustomerByPlaca(vehicle.id).then((Customer customer) {
          return customer;
        });
      } else {
        return null;
      }
    });
    return null;
  }

  @override
  void dispose() {
  }

  Future<DocumentReference> updateCustomer(Customer customer) async {
    return await _customerRepository.updateCustomer(customer);
  }

}