import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/customer/repository/customer_repository.dart';
import 'package:car_wash_app/vehicle/bloc/bloc_vehicle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class BlocCustomer implements Bloc {
  final _customerRepository = CustomerRepository();
  final _blocVehicle = BlocVehicle();

  //Casos de uso
  //1. Obtener Customer por Placa

  Future<Customer> getCustomerByVehicle(
      DocumentReference vehicleReference) async {
    return await _customerRepository.getCustomerByVehicle(vehicleReference);
  }

  Future<Customer> getCustomerByIdCustomer(
      String idCustomer) async {
    return await _customerRepository.getCustomerByIdCustomer(idCustomer);
  }

  Future<List<Customer>> getCustomerFilter(
      String telephoneNumber, String email) async {
    return await _customerRepository.getCustomerFilter(telephoneNumber, email);
  }

  Future<DocumentReference> updateCustomer(Customer customer) async {
    return await _customerRepository.updateCustomer(customer);
  }

  Future<DocumentReference> getCustomerReference(String customerId) async {
    return await _customerRepository.getCustomerReference(customerId);
  }

  Future<List<Customer>> getListCustomerReportByLocation(DocumentReference locationReference) async {
    return await _customerRepository.getCustomersByLocation(locationReference);
  }

  @override
  void dispose() {}
}
