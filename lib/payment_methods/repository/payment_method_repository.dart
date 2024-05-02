import 'package:car_wash_app/payment_methods/model/payment_methods.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PaymentMethodRepository {
  final Firestore _db = Firestore.instance;

  ///Get Payment Methods
  Stream<QuerySnapshot> getListPaymentMethodsStream() {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.paymentMethods)
        .where(FirestoreCollections.paymentActive, isEqualTo: true)
        .snapshots();
    return querySnapshot;
  }

  Stream<QuerySnapshot> getAllListPaymentMethodsStream() {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.paymentMethods)
        .snapshots();
    return querySnapshot;
  }

  List<PaymentMethod> buildPaymentMethods(
      List<DocumentSnapshot> paymentListSnapshot) {
    List<PaymentMethod> paymentsList = <PaymentMethod>[];
    paymentListSnapshot.forEach((p) {
      PaymentMethod loc = PaymentMethod.fromJson(p.data, id: p.documentID);
      paymentsList.add(loc);
    });
    return paymentsList;
  }

  Future<PaymentMethod> getPaymentMethodByName(String name) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.paymentMethods)
        .where(FirestoreCollections.paymentName, isEqualTo: name)
        .getDocuments();

    PaymentMethod pm = new PaymentMethod();
    if (querySnapshot.documents.length > 0) {
      pm = PaymentMethod.fromJson(querySnapshot.documents[0].data,
          id: querySnapshot.documents[0].documentID);
    }
    return pm;
  }

  DocumentReference getDocumentReferencePaymentsById(String idPMethod) {
    return _db.document('${FirestoreCollections.paymentMethods}/$idPMethod');
  }

  Future<DocumentReference> getPaymentMethodReference(String idPMethod) async {
    return _db.collection(FirestoreCollections.paymentMethods).document(idPMethod);
  }

  Future<DocumentReference> updatePaymentMethodDataRepository(PaymentMethod paymentMethod) async {
    DocumentReference ref = _db.collection(FirestoreCollections.paymentMethods).document(paymentMethod.id);
    ref.setData(paymentMethod.toJson(), merge: true);
    return ref;
  }

  ///Get all payment methods

  Future<PaymentMethod> getPaymentMethodById(String idPMethod) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.paymentMethods)
        .document(idPMethod)
        .get();

    return PaymentMethod.fromJson(querySnapshot.data, id: querySnapshot.documentID);
  }
}