
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/repository/invoice_repository.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsRepository {
  final Firestore _db = Firestore.instance;
  final _invoiceRepository = InvoiceRepository();

  ///Get productivity report list
  Stream<QuerySnapshot> getListProductivityReportStream(
      DocumentReference locationReference,
      DateTime dateInit,
      DateTime dateFinal,
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

    return querySnapshot.snapshots();
  }

  List<Invoice> buildListProductivityReport(List<DocumentSnapshot> invoicesListSnapshot) {
    List<Invoice> invoicesList = <Invoice>[];
    invoicesListSnapshot.forEach((p) {
      Invoice invoice = Invoice.fromJson(p.data, id: p.documentID);

      invoicesList.add(invoice);
    });
    return invoicesList;
  }
}