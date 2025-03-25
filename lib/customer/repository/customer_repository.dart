import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Customer> getCustomerByVehicle(
      DocumentReference vehicleReference) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.customers)
        .where(FirestoreCollections.customerFieldVehicles,
        arrayContains: vehicleReference)
        .orderBy(
        FirestoreCollections.customerFieldCreationDate, descending: true)
        .get();

    final documents = querySnapshot.docs;
    if (documents.length > 0) {
      final documentSnapshot = documents.first;
      return Customer.fromJson(
        documentSnapshot.data as Map<String, dynamic>,
        id: documentSnapshot.id,
      );
    }
    return Future.value(null);
  }

  Future<Customer> getCustomerByIdCustomer(String idCustomer) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.customers)
        .doc(idCustomer)
        .get();

    return Customer.fromJson(
      querySnapshot.data as Map<String, dynamic>,
      id: querySnapshot.id,
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

    querySnapshot = await queryFirestore.get();
    if (querySnapshot.docs.length > 0) {
      querySnapshot.docs.forEach((doc) {
        final customer = Customer.fromJson(doc.data as Map<String, dynamic>, id: doc.id);
        customerList.add(customer);
      });
    }

    return customerList;
  }

  Future<DocumentReference> updateCustomer(Customer customer) async {
    DocumentReference ref =
    _db.collection(FirestoreCollections.customers).doc(customer.id);
    ref.set(customer.toJson(), SetOptions(merge: true));
    return ref;
  }

  Future<DocumentReference> getCustomerReference(String customerId) async {
    return _db.collection(FirestoreCollections.customers).doc(customerId);
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

    querySnapshot = await queryFirestore.get();
    final responses = await Future.wait(
        querySnapshot.docs.map((p) {
            Invoice invoice = Invoice.fromJson(p.data as Map<String, dynamic>, id: p.id);
            return invoice.customer != null ? invoice.customer!.get() : Future.value(null);
        }),
    );

    customerList = responses.map((response) {
      Customer customerModel = Customer.fromJson(response?.data as Map<String, dynamic>, id: response?.id);
      return customerModel;
    }).toList();
    return  customerList;
  }
}
