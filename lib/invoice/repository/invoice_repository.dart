import 'dart:io';

import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class InvoiceRepository {

  String uid = '';

  final Firestore _db = Firestore.instance;
  final FirebaseAuth _authApi = FirebaseAuth.instance;
  final StorageReference _storageReference =FirebaseStorage.instance.ref();

  Future<DocumentReference> getUserReference() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    return _db.collection('users').document(user.uid);
  }

  Future<DocumentReference> updateInvoiceData(Invoice invoice) async {
    CollectionReference ref  = _db.collection('invoices');
    return await ref.add(invoice.toJson());
  }

  Future<StorageTaskSnapshot> uploadImageInvoice(String path, File imageFile) async {
    StorageUploadTask storageUploadTask = _storageReference.child(path).putData(
        imageFile.readAsBytesSync(),
      StorageMetadata(contentType: 'image/jpeg',),
    );
    return storageUploadTask.onComplete;
  }

  Future<void> updateInvoiceImages(String invoiceId, String invoiceImage) async {
    return await this
        ._db
        .collection('invoices')
        .document(invoiceId)
        .collection('images')
        .add({'imageUrl': invoiceImage});
  }

}