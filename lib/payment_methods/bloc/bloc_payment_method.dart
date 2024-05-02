import 'package:car_wash_app/payment_methods/model/payment_methods.dart';
import 'package:car_wash_app/payment_methods/repository/payment_method_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class BlocPaymentMethod implements Bloc {
  final _paymentMethodRepository = PaymentMethodRepository();

  Stream<QuerySnapshot> paymentMethodsStream() =>
      _paymentMethodRepository.getListPaymentMethodsStream();

  List<PaymentMethod> buildPaymentMethods(List<DocumentSnapshot> paymentMethodsListSnapshot) =>
      _paymentMethodRepository.buildPaymentMethods(paymentMethodsListSnapshot);

  Future<PaymentMethod> getPaymentMethodByName(String name) async => await _paymentMethodRepository.getPaymentMethodByName(name);

  Future<DocumentReference> updatePaymentMethodData(PaymentMethod location) async {
    DocumentReference ref = await _paymentMethodRepository.updatePaymentMethodDataRepository(location);
    return ref;
  }

  Future<DocumentReference> getPaymentMethodReference(String idPMethod) async {
    return await _paymentMethodRepository.getPaymentMethodReference(idPMethod);
  }

  Future<PaymentMethod> getPaymentMethodById(String idPMethod) async {
    return await _paymentMethodRepository.getPaymentMethodById(idPMethod);
  }

  DocumentReference getDocumentReferencePMethodById(String idLocation) => _paymentMethodRepository.getDocumentReferencePaymentsById(idLocation);

  Stream<QuerySnapshot> get allPaymentMethodsStream => _paymentMethodRepository.getAllListPaymentMethodsStream();

  @override
  void dispose() {
    // TODO: implement dispose
  }
}