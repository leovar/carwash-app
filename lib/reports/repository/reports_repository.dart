
import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/repository/invoice_repository.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _invoiceRepository = InvoiceRepository();

  ///Get productivity report list
  Stream<QuerySnapshot> getListProductivityReportStream(
      DocumentReference locationReference,
      DateTime dateInit,
      DateTime dateFinal,
      String companyId,
      ) {
    DateTime dateFinalModify =
    DateTime(dateFinal.year, dateFinal.month, dateFinal.day, 23, 59);

    var querySnapshot = this
        ._db
        .collection(FirestoreCollections.invoices)
        .where(FirestoreCollections.invoiceFieldCompanyId, isEqualTo: companyId)
        .where(FirestoreCollections.invoiceFieldCreationDate,
        isGreaterThanOrEqualTo: Timestamp.fromDate(dateInit))
        .where(FirestoreCollections.invoiceFieldCreationDate,
        isLessThanOrEqualTo: Timestamp.fromDate(dateFinalModify))
        .where(FirestoreCollections.invoiceFieldLocation,
        isEqualTo: locationReference)
        .where(FirestoreCollections.invoiceFieldCancelled, isEqualTo: false);

    return querySnapshot.snapshots();
  }

  List<Invoice> buildInvoiceListReport(List<DocumentSnapshot> invoicesListSnapshot) {
    List<Invoice> invoicesList = <Invoice>[];
    if (invoicesListSnapshot.isEmpty) {
      return invoicesList;
    }
    invoicesListSnapshot.forEach((p) {
      Invoice invoice = Invoice.fromJson(p.data() as Map<String, dynamic>, id: p.id);
      invoicesList.add(invoice);
    });
    return invoicesList;
  }

  ///Get Earnings report Data
  Stream<QuerySnapshot> getListEarningsReportStream(
      DateTime dateInit,
      DateTime dateFinal,
      String companyId
      ) {
    DateTime dateFinalModify =
    DateTime(dateFinal.year, dateFinal.month, dateFinal.day, 23, 59);

    var querySnapshot = this
        ._db
        .collection(FirestoreCollections.invoices)
        .where(FirestoreCollections.invoiceFieldCompanyId, isEqualTo: companyId)
        .where(FirestoreCollections.invoiceFieldCreationDate,
        isGreaterThanOrEqualTo: Timestamp.fromDate(dateInit))
        .where(FirestoreCollections.invoiceFieldCreationDate,
        isLessThanOrEqualTo: Timestamp.fromDate(dateFinalModify))
        .where(FirestoreCollections.invoiceFieldCancelled, isEqualTo: false)
        .where(FirestoreCollections.invoiceClosed, isEqualTo: true);

    return querySnapshot.snapshots();
  }

  ///Get Operator Productivity report
  Stream<QuerySnapshot> getOperatorInvoicesListCurrentMonth(DocumentReference locationReference, String companyId) {
    var _dateTimeInit = DateTime(DateTime.now().year, DateTime.now().month, 1);
    DateTime _dateTimeFinal = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59);

    var querySnapshot = this
        ._db
        .collection(FirestoreCollections.invoices)
        .where(FirestoreCollections.invoiceFieldCompanyId, isEqualTo: companyId)
        .where(FirestoreCollections.invoiceFieldCreationDate,
        isGreaterThanOrEqualTo: Timestamp.fromDate(_dateTimeInit))
        .where(FirestoreCollections.invoiceFieldCreationDate,
        isLessThanOrEqualTo: Timestamp.fromDate(_dateTimeFinal))
        .where(FirestoreCollections.invoiceFieldLocation,
        isEqualTo: locationReference);

    return querySnapshot.snapshots();
  }

  //TODO metodos hacia abajo solo se usan para corregir errores una sola vez, se deben eliminar
  Future<List<Invoice>> getAllInvoices() async {
    List<Invoice> invoiceList = <Invoice>[];
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.invoices)
        .where(FirestoreCollections.invoiceFieldLocationName, isEqualTo: 'PRUEBAS')
        .get();

    final documents = querySnapshot.docs;
    if (documents.length > 0) {
      documents.forEach((document) {
        Invoice product = Invoice.fromJson(document.data(), id: document.id);
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
          isLessThanOrEqualTo: Timestamp.fromDate(dateFinalModify));

    if (locationReference.id != 'defaultDocId') {
      queryFirestore = queryFirestore.where(FirestoreCollections.invoiceFieldLocation,
          isEqualTo: locationReference);
    }
  
    querySnapshot = await queryFirestore.get();
    final responses = await Future.wait(
      querySnapshot.docs.map((p) async {
        Invoice invoice = Invoice.fromJson(p.data() as Map<String, dynamic>, id: p.id);
        final customerResponse = await invoice.customer?.get();
        Customer cus = Customer.fromJson(customerResponse?.data() as Map<String, dynamic>, id: customerResponse?.id);
        Invoice newInvoice = Invoice.copyWith(origin: invoice, customerName: cus.name, customerPhone: cus.phoneNumber);
        invoicesList.add(newInvoice);
      }),
    );
    return invoicesList;
  }
}
