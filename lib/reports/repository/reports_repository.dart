
import 'package:car_wash_app/customer/model/customer.dart';
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


  //TODO metodos hacia abajo solo se usan para corregir errores una sola vez, se deben eliminar
  Future<List<Invoice>> getAllInvoices() async {
    List<Invoice> invoiceList = <Invoice>[];
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.invoices)
        .getDocuments();

    final documents = querySnapshot.documents;
    if (documents.length > 0) {
      documents.forEach((document) {
        Invoice product = Invoice.fromJson(document.data, id: document.documentID);
        invoiceList.add(product);
      });
    }
    return invoiceList;
  }

  Future<List<Invoice>> getCustomerInvoicesByLocation (DocumentReference locationReference, DateTime dateInit, DateTime dateFinal) async {
    List<Invoice> invoicesList = [];
    QuerySnapshot querySnapshot;

    DateTime dateFinalModify = DateTime(dateFinal.year, dateFinal.month, dateFinal.day, 23, 59);

    var queryFirestore = this
        ._db
        .collection(FirestoreCollections.invoices)
        .where(FirestoreCollections.invoiceFieldCreationDate,
          isGreaterThanOrEqualTo: Timestamp.fromDate(dateInit))
        .where(FirestoreCollections.invoiceFieldCreationDate,
          isLessThanOrEqualTo: Timestamp.fromDate(dateFinalModify))
        .where(FirestoreCollections.invoiceFieldLocation,
        isEqualTo: locationReference);

    querySnapshot = await queryFirestore.getDocuments();
    final responses = await Future.wait(
      querySnapshot.documents.map((p) async {
        Invoice invoice = Invoice.fromJson(p.data, id: p.documentID);
        final customerResponse = await invoice.customer.get();
        Customer cus = Customer.fromJson(customerResponse.data, id: customerResponse.documentID);
        Invoice newInvoice = Invoice.copyWith(origin: invoice, customerName: cus.name, customerPhone: cus.phoneNumber);
        invoicesList.add(newInvoice);
      }),
    );
    return invoicesList;
  }
}