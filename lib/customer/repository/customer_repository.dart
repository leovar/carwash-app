import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerRepository {

  final Firestore _db = Firestore.instance;

  Future<Customer> getCustomerByPlaca(String placa) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.customers)
        .where(FirestoreCollections.customerFieldVehicles, arrayContains: _db.document('${FirestoreCollections.vehicles}/$placa'))
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

  Future<DocumentReference> updateCustomer(Customer customer) async {
    DocumentReference ref =
    _db
        .collection(FirestoreCollections.customers)
        .document(customer.id);
    ref.setData(customer.toJson(), merge: true);
    return ref;
  }
}