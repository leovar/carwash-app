import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:car_wash_app/invoice/model/additional_product.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/vehicle/model/vehicle.dart';
import 'package:car_wash_app/vehicle_type/model/vehicleType.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class InvoiceRepository {
  String uid = '';

  final Firestore _db = Firestore.instance;
  final FirebaseAuth _authApi = FirebaseAuth.instance;
  final StorageReference _storageReference = FirebaseStorage.instance.ref();

  /// Save and Update Invoice
  Future<DocumentReference> updateInvoiceData(Invoice invoice) async {
    DocumentReference ref =
        _db.collection(FirestoreCollections.invoices).document(invoice.id);
    ref.setData(invoice.toJson(), merge: true);
    return ref;
  }

  /// Save invoice images in firebase storage
  Future<StorageTaskSnapshot> uploadImageInvoice(
      String path, File imageFile) async {
    StorageUploadTask storageUploadTask = _storageReference.child(path).putData(
          imageFile.readAsBytesSync(),
          StorageMetadata(
            contentType: 'image/jpeg',
          ),
        );
    return storageUploadTask.onComplete;
  }

  ///Save Firm Image in firebase storage
  Future<StorageTaskSnapshot> uploadImageFirmInvoice(
      String path, Uint8List imageFile) async {
    StorageUploadTask storageUploadTask = _storageReference.child(path).putData(
          imageFile,
          StorageMetadata(
            contentType: 'image/jpeg',
          ),
        );
    return storageUploadTask.onComplete;
  }

  /// Save images URL in subcollection invoice
  Future<void> updateInvoiceImages(
      String invoiceId, String invoiceImage) async {
    return await this
        ._db
        .collection(FirestoreCollections.invoices)
        .document(invoiceId)
        .collection('images')
        .add({'imageUrl': invoiceImage});
  }

  ///Get Operators list by Location
  Stream<QuerySnapshot> getListOperatorsStream() {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldIsOperator, isEqualTo: true)
        .where(FirestoreCollections.usersFieldUserActive, isEqualTo: true)
        .snapshots();
    return querySnapshot;
  }

  List<User> buildOperators(List<DocumentSnapshot> operatorsListSnapshot) {
    List<User> usersList = <User>[];
    operatorsListSnapshot.forEach((p) {
      User loc = User.fromJson(p.data, id: p.documentID);
      usersList.add(loc);
    });
    return usersList;
  }

/*
  Future<List<User>> getOperatorsUsers() async {
    List<User> userList = <User>[];
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldIsOperator, isEqualTo: true)
        .getDocuments();

    final snapShot = querySnapshot.documents;
    snapShot.forEach((document) {
      User user = User.fromJson(document.data, id: document.documentID);
      userList.add(user);
    });
    return userList;
  }*/

  /// Get Coordinators list by Location
  Stream<QuerySnapshot> getListCoordinatorStream() {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldIsCoordinator, isEqualTo: true)
        .where(FirestoreCollections.usersFieldUserActive, isEqualTo: true)
        .snapshots();
    return querySnapshot;
  }

  List<User> buildCoordinator(List<DocumentSnapshot> coordinatorListSnapshot) {
    List<User> usersList = <User>[];
    coordinatorListSnapshot.forEach((p) {
      User loc = User.fromJson(p.data, id: p.documentID);
      usersList.add(loc);
    });
    return usersList;
  }

  /// Get Brands list by vehicleType
  Stream<QuerySnapshot> getListBrandsStream(int uidVehicleType) {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.brands)
        .where(FirestoreCollections.brandFieldVehicleType,
            isEqualTo: uidVehicleType)
        .snapshots();
    return querySnapshot;
  }

  List<String> buildBrands(List<DocumentSnapshot> brandsListSnapshot) {
    List<String> brandsList = <String>[];
    brandsListSnapshot.forEach((p) {
      String brand = p.data['brand'];
      brandsList.add(brand);
    });
    return brandsList;
  }

  /// Get Colors list by vehicleType
  Stream<QuerySnapshot> getListColorsStream(int uidVehicleType) {
    final querySnapshot =
        this._db.collection(FirestoreCollections.colors).snapshots();
    return querySnapshot;
  }

  List<String> buildColors(List<DocumentSnapshot> colorsListSnapshot) {
    List<String> colorsList = <String>[];
    colorsListSnapshot.forEach((p) {
      String brand = p.data['color'];
      colorsList.add(brand);
    });
    return colorsList;
  }

  /*Future<List<User>> getCoordinatorUsers() async {
    List<User> userList = <User>[];
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldIsCoordinator, isEqualTo: true)
        .getDocuments();

    final snapShot = querySnapshot.documents;
    snapShot.forEach((document) {
      User user = User.fromJson(document.data, id: document.documentID);
      userList.add(user);
    });
    return userList;
  }*/

  /// Get Vehicle Reference
  Future<DocumentReference> getVehicleTypeReference(String vehicleType) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.vehicleType)
        .where(FirestoreCollections.vehicleTypeFieldVehicleType,
            isEqualTo: vehicleType)
        .getDocuments();

    final documents = querySnapshot.documents;
    if (documents.length > 0) {
      final documentSnapshot = documents.first;
      return _db
          .collection(FirestoreCollections.vehicleType)
          .document(documentSnapshot.documentID);
    }
    return null;
  }

  /// Save Invoice Products
  Future<void> saveInvoiceProduct(String invoiceId, Product product) async {
    await this
        ._db
        .collection(FirestoreCollections.invoices)
        .document(invoiceId)
        .collection(FirestoreCollections.products)
        .add(Product().toJsonInvoiceProduct(
          product.productName,
          product.price,
          product.ivaPercent,
          false,
          product.id,
        ));
  }

  /// Save Invoice Additional Products
  Future<void> saveInvoiceAdditionalProducts(
      String invoiceId, AdditionalProduct additionalProduct) async {
    await this
        ._db
        .collection(FirestoreCollections.invoices)
        .document(invoiceId)
        .collection(FirestoreCollections.products)
        .add(Product().toJsonInvoiceProduct(
          additionalProduct.productName,
          double.parse(additionalProduct.productValue),
          additionalProduct.ivaPercent,
          true,
          null,
        ));
  }

  ///Get invoices list from current Month
  Stream<QuerySnapshot> getListInvoicesByMonthStream(
    DocumentReference locationReference,
    DateTime dateInit,
    DateTime dateFinal,
    String placa,
    String operator,
    String consecutive,
  ) {
    DateTime dateFinalModify =
        DateTime(dateFinal.year, dateFinal.month, dateFinal.day, 23, 59);

    var querySnapshot = this
        ._db
        .collection(FirestoreCollections.invoices)
        .where(FirestoreCollections.invoiceFieldCreationDate,
            isGreaterThanOrEqualTo: Timestamp.fromDate(dateInit))
        .where(FirestoreCollections.invoiceFieldCreationDate,
            isLessThanOrEqualTo: Timestamp.fromDate(dateFinalModify))
        .where(FirestoreCollections.invoiceFieldLocation,
            isEqualTo: locationReference);

    if (placa.isNotEmpty) {
      querySnapshot = querySnapshot
          .where(FirestoreCollections.invoiceFieldPlaca, isEqualTo: placa);
    }

    if (operator.isNotEmpty) {
      querySnapshot = querySnapshot.where(
          FirestoreCollections.invoiceFieldUserOperatorName,
          isEqualTo: operator);
    }

    if (consecutive.isNotEmpty) {
      querySnapshot = querySnapshot.where(
          FirestoreCollections.invoiceFieldConsecutive,
          isEqualTo: int.parse(consecutive) );
    }

    return querySnapshot.snapshots();
  }

  List<Invoice> buildInvoicesListByMonth(
      List<DocumentSnapshot> invoicesListSnapshot) {
    List<Invoice> invoicesList = <Invoice>[];
    invoicesListSnapshot.forEach((p) {
      Invoice loc = Invoice.fromJson(p.data, id: p.documentID);
      invoicesList.add(loc);
    });
    return invoicesList;
  }

  Future<List<Product>> getInvoiceProducts(String idInvoice) async {
    List<Product> productList = <Product>[];
    var querySnapshot = await this
        ._db
        .collection(FirestoreCollections.invoices)
        .document(idInvoice)
        .collection(FirestoreCollections.invoiceFieldProducts)
        .getDocuments();

    final documents = querySnapshot.documents;
    if (documents.length > 0) {
      documents.forEach((document) {
        Product product =
            Product.fromJson(document.data, id: document.documentID);
        productList.add(product);
      });
    }
    return productList;
  }

  ///Get last consecutive for location
  Future<int> getLastConsecutiveByLocation(
      DocumentReference locationReference) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.invoices)
        .where(FirestoreCollections.invoiceFieldLocation,
            isEqualTo: locationReference)
        .orderBy(FirestoreCollections.invoiceFieldConsecutive, descending: true)
        .limit(3)
        .getDocuments();

    final documents = querySnapshot.documents;
    if (documents.length > 0) {
      Invoice invoice = Invoice.fromJson(documents.first.data,
          id: documents.first.documentID);
      if (invoice.consecutive != null && invoice.consecutive > 0) {
        return invoice.consecutive;
      } else {
        return 0;
      }
    }
    return 0;
  }

  /// Get products per invoice
  Future<List<Product>> getProductsByIdInvoice(String invoiceId) async {
    List<Product> productList = <Product>[];
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.invoices)
        .document(invoiceId)
        .collection(FirestoreCollections.invoiceFieldProducts)
        .getDocuments();

    final documents = querySnapshot.documents;
    if (documents.length > 0) {
      documents.forEach((product) {
        Product productGet =
            Product.fromJsonProInvoice(product.data, id: product.documentID);
        productList.add(productGet);
      });
    }
    return productList;
  }

  /// Get invoices images
  Future<List<String>> getImagesByIdInvoice(String invoiceId) async {
    List<String> imageList = <String>[];
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.invoices)
        .document(invoiceId)
        .collection(FirestoreCollections.invoiceFieldImages)
        .getDocuments();

    final documents = querySnapshot.documents;
    if (documents.length > 0) {
      documents.forEach((product) {
        String imageGet = product.data['imageUrl'];
        imageList.add(imageGet);
      });
    }
    return imageList;
  }

  /// Get Invoice By Id Invoice
  Future<Invoice> getInvoiceByIdInvoice(String invoiceId) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.invoices)
        .document(invoiceId)
        .get();

    return Invoice.fromJson(querySnapshot.data, id: querySnapshot.documentID);
  }

  /// Get List Invoices by Placa
  Future<List<Invoice>> getListInvoicesByVehicle(String vehicleId) async {
    var date = DateTime.now();
    var newDate = DateTime(date.year, date.month + 2, date.day);
    List<Invoice> listInvoices = [];
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.invoices)
        .where(FirestoreCollections.invoiceFieldPlaca, isEqualTo: vehicleId)
        .where(FirestoreCollections.invoiceFieldCreationDate, isLessThanOrEqualTo: newDate)
        .getDocuments();

    final documents = querySnapshot.documents;
    if (documents.length > 0) {
      documents.forEach((invoice) {
        listInvoices.add(Invoice.fromJson(invoice.data, id: invoice.documentID));
      });
    }
    return listInvoices;
  }
}
