import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerRepository {
  final Firestore _db = Firestore.instance;

  Future<Customer> getCustomerByVehicle(
      DocumentReference vehicleReference) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.customers)
        .where(FirestoreCollections.customerFieldVehicles,
        arrayContains: vehicleReference)
        .orderBy(
        FirestoreCollections.customerFieldCreationDate, descending: true)
        .getDocuments();

    final documents = querySnapshot.documents;
    if (documents.length > 0) {
      final documentSnapshot = documents.first;
      return Customer.fromJson(
        documentSnapshot.data,
        id: documentSnapshot.documentID,
      );
    }
    return null;
  }

  Future<Customer> getCustomerByIdCustomer(String idCustomer) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.customers)
        .document(idCustomer)
        .get();

    return Customer.fromJson(
      querySnapshot.data,
      id: querySnapshot.documentID,
    );
  }

  Future<List<Customer>> getCustomerFilter(String telephoneNumber,
      String email) async {
    List<Customer> customerList = [];
    QuerySnapshot querySnapshot;
    var queryFirestore = this
        ._db
        .collection(FirestoreCollections.customers)
        .where(FirestoreCollections.customerFieldCreationDate,
        isLessThan: Timestamp.now());

    if (telephoneNumber.isNotEmpty) {
      queryFirestore = queryFirestore.where(
          FirestoreCollections.customerFieldPhoneNumber,
          isEqualTo: telephoneNumber);
    }

    if (email.isNotEmpty) {
      queryFirestore = queryFirestore.where(
          FirestoreCollections.customerFieldEmail,
          isEqualTo: email.toLowerCase());
    }

    querySnapshot = await queryFirestore.getDocuments();
    if (querySnapshot.documents.length > 0) {
      querySnapshot.documents.forEach((doc) {
        final customer = Customer.fromJson(doc.data, id: doc.documentID);
        customerList.add(customer);
      });
    }

    return customerList;
  }

  Future<DocumentReference> updateCustomer(Customer customer) async {
    DocumentReference ref =
    _db.collection(FirestoreCollections.customers).document(customer.id);
    ref.setData(customer.toJson(), merge: true);
    return ref;
  }

  Future<DocumentReference> getCustomerReference(String customerId) async {
    return _db.collection(FirestoreCollections.customers).document(customerId);
  }

  Future<List<Customer>> getCustomersByLocation(
      DocumentReference locationReference) async {
    List<Customer> customerList = [];
    QuerySnapshot querySnapshot;
    var queryFirestore = this
        ._db
        .collection(FirestoreCollections.invoices)
        .where(FirestoreCollections.invoiceFieldLocation,
        isEqualTo: locationReference);

    querySnapshot = await queryFirestore.getDocuments();
    final responses = await Future.wait(
        querySnapshot.documents.map((p) {
            Invoice invoice = Invoice.fromJson(p.data, id: p.documentID);
            return invoice.customer.get();
        }),
    );

    customerList = responses.map((response) {
      Customer customerModel = Customer.fromJson(response.data, id: response.documentID);
      return customerModel;
    }).toList();

    return  customerList;
  }
}
