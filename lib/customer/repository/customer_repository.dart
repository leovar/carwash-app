import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerRepository {
  final Firestore _db = Firestore.instance;

  Future<Customer> getCustomerByVehicle(
      DocumentReference vehicleReference) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.customers)
        .where(FirestoreCollections.customerFieldVehicles, arrayContains: vehicleReference)
        .orderBy(FirestoreCollections.customerFieldCreationDate, descending: true)
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

  Future<Customer> getCustomerByIdCustomer(
      String idCustomer) async {
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

  Future<DocumentReference> getCustomerFilter(String telephoneNumber, String email, String name) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.customers)
        .where(FirestoreCollections.customerFieldPhoneNumber, isEqualTo: telephoneNumber)
        .getDocuments();

    final documents = querySnapshot.documents;
    if (documents.length > 0) {
      return documents.first.reference;
    }
    return null;
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
}
