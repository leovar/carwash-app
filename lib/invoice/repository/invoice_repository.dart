import 'dart:io';

import 'package:car_wash_app/invoice/model/additional_product.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/user/model/user.dart';
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

  /// Guarda y actualiza la factura
  Future<DocumentReference> updateInvoiceData(Invoice invoice) async {
    CollectionReference ref = _db.collection(FirestoreCollections.invoices);
    return await ref.add(invoice.toJson());
  }

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

  /// Guarda las url de las imagenes en una subcolection de la factura
  Future<void> updateInvoiceImages(
      String invoiceId, String invoiceImage) async {
    return await this
        ._db
        .collection(FirestoreCollections.invoices)
        .document(invoiceId)
        .collection('images')
        .add({'imageUrl': invoiceImage});
  }

  /// Obtiene la lista de los oeradores segun el Location
  Stream<QuerySnapshot> getListOperatorsStream() {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldIsOperator, isEqualTo: true)
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

  ///Get Operators From simple consult
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
  }

  /// Obtiene la lista de usuarios Coordinadores de la base de datos
  Stream<QuerySnapshot> getListCoordinatorStream() {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldIsCoordinator, isEqualTo: true)
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

  Future<void> saveInvoiceProduct(String invoiceId, Product product) async {
    await this
        ._db
        .collection(FirestoreCollections.invoices)
        .document(invoiceId)
        .collection(FirestoreCollections.products)
        .add(Product().toJsonInvoiceProduct(
            product.productName, product.price, product.iva, false));
  }

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
}
