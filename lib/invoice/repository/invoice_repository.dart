import 'dart:io';

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
    CollectionReference ref = _db.collection(FirestoreCollections.invoices);
    return await ref.add(invoice.toJson());
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
  Stream<QuerySnapshot> getListOperatorsStream(
      DocumentReference locationReference) {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldIsOperator, isEqualTo: true)
        .where(FirestoreCollections.usersFieldIsOperator)
        .where(FirestoreCollections.usersFieldLocations,
            arrayContains: locationReference)
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
  Stream<QuerySnapshot> getListCoordinatorStream(
      DocumentReference locationReference) {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldIsCoordinator, isEqualTo: true)
        .where(FirestoreCollections.usersFieldLocations,
            arrayContains: locationReference)
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
            product.productName, product.price, product.iva, false));
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
            additionalProduct.productIva,
            true));
  }

  ///Get invoices list from current Month
  Stream<QuerySnapshot> getListInvoicesByMonthStream(
      DocumentReference locationReference, DateTime date) {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.invoices)
        .where(FirestoreCollections.invoiceFieldCreationDate,
            isGreaterThanOrEqualTo: Timestamp.fromDate(date))
        .where(FirestoreCollections.invoiceFieldLocation, isEqualTo: locationReference)
        .snapshots();
    return querySnapshot;
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
}
