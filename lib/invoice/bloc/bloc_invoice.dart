import 'dart:io';

import 'package:car_wash_app/invoice/model/additional_product.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/repository/invoice_repository.dart';
import 'package:car_wash_app/invoices_list/model/invoice_list_model.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/vehicle/model/vehicle.dart';
import 'package:car_wash_app/vehicle/repository/vehicle_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:path/path.dart';

class BlocInvoice implements Bloc {

  final _invoiceRepository = InvoiceRepository();
  final _vehicleRepository = VehicleRepository();

  //Casos de uso del objeto User
  //1. guardar nueva factura
  //2. guardar las imagenes de la factura
  //3. guardar las url de las fotos en la factura creada

  Future<DocumentReference> saveInvoice(Invoice invoice) async {

    DocumentReference ref = await _invoiceRepository.updateInvoiceData(invoice);
    String invoiceId = ref.documentID;

    if (invoice.invoiceImages != null && invoice.invoiceImages.length > 0 ) {
      for(String imageFilePath in invoice.invoiceImages) {
        File imageFile = File(imageFilePath);
        final pathImage = '$invoiceId/before/${basename(imageFilePath)}';
        StorageTaskSnapshot storageTaskSnapshot = await _invoiceRepository.uploadImageInvoice(pathImage, imageFile);
        String imageUrl = await storageTaskSnapshot.ref.getDownloadURL();
        await _invoiceRepository.updateInvoiceImages(invoiceId, imageUrl);
      }
    }
    return ref;
  }

  Future<DocumentReference> getVehicleTypeReference(String vehicleType) {
    return _invoiceRepository.getVehicleTypeReference(vehicleType);
  }

  Stream<QuerySnapshot> operatorsStream(DocumentReference locationReference) {
    return locationReference != null ? _invoiceRepository.getListOperatorsStream(locationReference): QuerySnapshot;
  }
  List<User> buildOperators(List<DocumentSnapshot> operatorsListSnapshot) => _invoiceRepository.buildOperators(operatorsListSnapshot);
  /*Future<List<User>> getOperatorsUsers() {
    return _invoiceRepository.getOperatorsUsers();
  }*/

  Stream<QuerySnapshot> coordinatorsStream(DocumentReference locationReference) {
    return locationReference != null ? _invoiceRepository.getListCoordinatorStream(locationReference): QuerySnapshot;
  }
  List<User> buildCoordinators(List<DocumentSnapshot> coordinatorListSnapshot) => _invoiceRepository.buildCoordinator(coordinatorListSnapshot);
  /*Future<List<User>> getCoordinatorUser() {
    return _invoiceRepository.getCoordinatorUsers();
  }*/

  Stream<QuerySnapshot> invoicesListByMonthStream(DocumentReference locationReference, DateTime date) {
    return _invoiceRepository.getListInvoicesByMonthStream(locationReference, date);
  }
  List<Invoice> buildInvoicesListByMonth(List<DocumentSnapshot> invoicesListSnapshot) => _invoiceRepository.buildInvoicesListByMonth(invoicesListSnapshot);


  Future<void> saveInvoiceProduct(String invoiceId, List<Product> listProducts) async {
    listProducts.forEach((product) {
      _invoiceRepository.saveInvoiceProduct(invoiceId, product);
    });
  }

  Future<void> saveInvoiceAdditionalProducts(String invoiceId, List<AdditionalProduct> additionalProducts) async {
    additionalProducts.forEach((addProduct) {
      _invoiceRepository.saveInvoiceAdditionalProducts(invoiceId, addProduct);
    });
  }

  Future<List<Product>> getInvoiceProducts (String idInvoice) => _invoiceRepository.getInvoiceProducts(idInvoice);


  @override
  void dispose() {
  }

}