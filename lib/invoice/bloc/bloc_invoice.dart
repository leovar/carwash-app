import 'dart:io';

import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/repository/invoice_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:path/path.dart';

class BlocInvoice implements Bloc {

  final _invoiceRepository = InvoiceRepository();

  //Casos de uso del objeto User
  //1. guardar nueva factura

  Future<DocumentReference> getUserReference() async {
    return _invoiceRepository.getUserReference();
  }

  Future<void> saveInvoice(Invoice invoice) async {

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
  }


  @override
  void dispose() {
    // TODO: implement dispose
  }

}