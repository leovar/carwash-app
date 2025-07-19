import 'dart:io';
import 'dart:typed_data';

import 'package:car_wash_app/invoice/model/additional_product.dart';
import 'package:car_wash_app/invoice/model/configuration.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/payment_methods/model/payment_methods.dart';
import 'package:car_wash_app/invoice/repository/invoice_repository.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/user/model/sysUser.dart';
import 'package:car_wash_app/vehicle/repository/vehicle_repository.dart';
import 'package:car_wash_app/vehicle_type/model/brand.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class BlocInvoice implements Bloc {
  final _invoiceRepository = InvoiceRepository();
  final _vehicleRepository = VehicleRepository();

  //Casos de uso del objeto User
  //1. guardar nueva factura
  //2. guardar las imagenes de la factura
  //3. guardar las url de las fotos en la factura creada
  //4. consultar y generar nuevo consecutivo

  /// Save Invoice and products
  Future<DocumentReference> saveInvoice(Invoice invoice) async {
    DocumentReference ref = await _invoiceRepository.updateInvoiceData(invoice);
    String invoiceId = ref.id;
    _saveImages(invoice, invoiceId);
    return ref;
  }

  void _saveImages(Invoice invoice, String invoiceId) async {
    try{
      if ((invoice.invoiceImages?.length??0) > 0) {
        final storage = FirebaseStorage.instance;

        for (String imageFilePath in invoice.invoiceImages??[]) {
          if (!imageFilePath.contains('https://firebasestorage.')) {
            File imageFile = File(imageFilePath);
            final pathImage = imageFilePath.contains('imageFirm')
                ? '$invoiceId/before/firm'
                : '$invoiceId/before/${basename(imageFilePath)}';
            final storageTaskSnapshot = await _invoiceRepository.uploadImageInvoice(pathImage, imageFile);
            String imageUrl = await storageTaskSnapshot.ref.getDownloadURL();
            String imagePath = await storageTaskSnapshot.ref.fullPath;
            await _invoiceRepository.updateInvoiceImages(invoiceId, imageUrl, imagePath);
          }
        }
        final dir = await path_provider.getTemporaryDirectory();
        dir.deleteSync(recursive: true);
        Fluttertoast.showToast(msg: "Imagenes guardadas de la factura # ${invoice.consecutive}", toastLength: Toast.LENGTH_LONG);
      }
    } catch(err) {
      throw(err);
    }
  }

  ///TODO metodo unicamente usado para actualziar la compania en las facturas, no guarda ni actualzia imagenes, se debe eliminar cuando se actualicen las companias en las facturas
  Future<DocumentReference> updateCompanyInvoice(Invoice invoice) async {
    DocumentReference ref = await _invoiceRepository.updateInvoiceData(invoice);
    return ref;
  }

  Future<DocumentReference> getVehicleTypeReference(String vehicleType) {
    return _invoiceRepository.getVehicleTypeReference(vehicleType);
  }

  /// Operators
  Stream<QuerySnapshot> operatorsStream(String companyId) =>
      _invoiceRepository.getListOperatorsStream(companyId);

  Stream<QuerySnapshot> operatorsByLocationStream(String idLocation, String companyId) =>
      _invoiceRepository.getListOperatorsByLocationStream(idLocation, companyId);

  List<SysUser> buildOperators(List<DocumentSnapshot> operatorsListSnapshot) =>
      _invoiceRepository.buildOperators(operatorsListSnapshot);

  /*Future<List<User>> getOperatorsUsers() {
    return _invoiceRepository.getOperatorsUsers();
  }*/

  /// Coordinators
  Stream<QuerySnapshot> coordinatorsStream() =>
      _invoiceRepository.getListCoordinatorStream();

  Stream<QuerySnapshot> coordinatorsByLocationStream(String idLocation, String companyId) =>
      _invoiceRepository.getListCoordinatorByLocationStream(idLocation, companyId);

  List<SysUser> buildCoordinators(
          List<DocumentSnapshot> coordinatorListSnapshot) =>
      _invoiceRepository.buildCoordinator(coordinatorListSnapshot);

  /*Future<List<User>> getCoordinatorUser() {
    return _invoiceRepository.getCoordinatorUsers();
  }*/

  /// Brands
  Stream<QuerySnapshot> brandsStream(int uidVehicleType) {
    return _invoiceRepository.getListBrandsStream(uidVehicleType);
  }

  Stream<QuerySnapshot> allBrandsStream() {
    return _invoiceRepository.getListAllBrandsStream();
  }

  List<String> buildBrandsInvoice(List<DocumentSnapshot> brandsListSnapshot) {
    List<String> brands =
        _invoiceRepository.buildBrandsInvoice(brandsListSnapshot);
    brands.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return brands;
  }

  List<Brand> buildBrands(List<DocumentSnapshot> brandsListSnapshot) {
    List<Brand> brands = _invoiceRepository.buildBrands(brandsListSnapshot);
    brands
        .sort((a, b) => (a.brand??'').toLowerCase().compareTo((b.brand??'').toLowerCase()));
    return brands;
  }

  Future<List<String>> getAllBrandsInvoice() async {
    List<String> brandList = [];
    brandList = await _invoiceRepository.getListAllBrandsInvoiceRepo();
    brandList.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return brandList;
  }

  /// Brands References
  Future<List<String>> getBrandReferences(String brand) async {
    List<String> brandReferenceList = [];
    if (brand.isNotEmpty) {
      String brandId = await _invoiceRepository.getBrandByBrand(brand);
      brandReferenceList = await _invoiceRepository.getBrandReferences(brandId);
      brandReferenceList
          .sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    }
    return brandReferenceList;
  }

  /// Colors
  Stream<QuerySnapshot> colorsStream(int uidVehicleType) {
    return _invoiceRepository.getListColorsStream(uidVehicleType);
  }

  List<String> buildColors(List<DocumentSnapshot> colorsListSnapshot) {
    List<String> colors = _invoiceRepository.buildColors(colorsListSnapshot);
    colors.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return colors;
  }

  /// List Invoices per month
  Stream<QuerySnapshot> invoicesListByMonthStream(
    DocumentReference locationReference,
    DateTime dateInit,
    DateTime dateFinal,
    String placa,
    String consecutive,
    String productTypeSelected,
    String paymentMethod,
    String companyId,
  ) {
    return _invoiceRepository.getListInvoicesByMonthStream(
      locationReference,
      dateInit,
      dateFinal,
      placa,
      consecutive,
      productTypeSelected,
      paymentMethod,
      companyId,
    );
  }

  List<Invoice> buildInvoicesListByMonth(
      List<DocumentSnapshot> invoicesListSnapshot) {
    return _invoiceRepository.buildInvoicesListFromSnapshot(invoicesListSnapshot);
  }

  /// Get invoices pending for Washing
  Stream<QuerySnapshot> invoicesListPendingWashingStream(DocumentReference? locationReference, String companyId) {
    return _invoiceRepository.getInvoicesListPendingWashingStream(locationReference, companyId);
  }

  List<Invoice> buildInvoicesListPendingWashing(List<DocumentSnapshot> invoicesListSnapshot) {
    return _invoiceRepository.buildInvoicesListFromSnapshot(invoicesListSnapshot);
  }

  Future<List<Invoice>> getListPendingWashList(DocumentReference? locationReference, String companyId) async {
    return await _invoiceRepository.getInvoicesListPendingWashing(locationReference, companyId);
  }

  /// Get invoices current Wash
  Stream<QuerySnapshot> invoicesListWashingStream(DocumentReference? locationReference, String companyId) {
    return _invoiceRepository.getInvoicesListWashingStream(locationReference, companyId);
  }

  List<Invoice> buildInvoicesListWashing(List<DocumentSnapshot> invoicesListSnapshot) {
    return _invoiceRepository.buildInvoicesListFromSnapshot(invoicesListSnapshot);
  }

  Future<List<Invoice>> invoicesWashingList(DocumentReference? locationReference, String companyId) async {
    return await _invoiceRepository.getInvoicesWashingList(locationReference, companyId);
  }

  /// Get invoices list for placa in the last 2 months
  Future<List<Invoice>> getListInvoicesByVehicle(String plate, String companyId) async {
    return await _invoiceRepository.getListInvoicesByVehicle(plate, companyId);
  }

  Future<int> getLastConsecutiveByLocation(DocumentReference locationReference, String companyId) =>
      _invoiceRepository.getLastConsecutiveByLocation(locationReference, companyId);

  Future<List<String>> getInvoiceImages(String invoiceId) {
    return _invoiceRepository.getImagesByIdInvoice(invoiceId);
  }

  Future<Invoice> getInvoiceById(String invoiceId) {
    return _invoiceRepository.getInvoiceByIdInvoice(invoiceId);
  }

  Future<Configuration> getConfigurationObject(String companyId) {
    return _invoiceRepository.getConfiguration(companyId);
  }

  Future<QuerySnapshot> getAllInvoicesBatch(int batchSize, DocumentSnapshot? doc) async {
    return _invoiceRepository.getAllInvoicesPerBatch(batchSize, doc);
  }

  Future<void> updateInvoicesBatch(List<QueryDocumentSnapshot> docs, String companyId) async {
    _invoiceRepository.getBatchInvoices(docs, companyId);
  }

  Future<int?> getInvoicesTotalCount() async {
    return _invoiceRepository.getInvoicesCountFunction();
    //return _invoiceRepository.updateBatchInvoicesFunction();
    //_invoiceRepository.uploadRegions();
    //return 0;
  }

  @override
  void dispose() {}
}
