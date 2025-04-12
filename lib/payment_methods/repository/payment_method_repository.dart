import 'package:car_wash_app/payment_methods/model/payment_methods.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PaymentMethodRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
      PaymentMethod loc = PaymentMethod.fromJson(p.data() as Map<String, dynamic>, id: p.id);
      paymentsList.add(loc);
    });
    return paymentsList;
  }

  Future<PaymentMethod> getPaymentMethodByName(String name) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.paymentMethods)
        .where(FirestoreCollections.paymentName, isEqualTo: name)
        .get();

    PaymentMethod pm = new PaymentMethod();
    if (querySnapshot.docs.length > 0) {
      pm = PaymentMethod.fromJson(querySnapshot.docs[0].data(),
          id: querySnapshot.docs[0].id);
    }
    return pm;
  }

  DocumentReference getDocumentReferencePaymentsById(String idPMethod) {
    return _db.doc('${FirestoreCollections.paymentMethods}/$idPMethod');
  }

  Future<DocumentReference> getPaymentMethodReference(String idPMethod) async {
    return _db.collection(FirestoreCollections.paymentMethods).doc(idPMethod);
  }

  Future<DocumentReference> updatePaymentMethodDataRepository(PaymentMethod paymentMethod) async {
    DocumentReference ref = _db.collection(FirestoreCollections.paymentMethods).doc(paymentMethod.id);
    await ref.set(paymentMethod.toJson(), SetOptions(merge: true));
    return ref;
  }

  ///Get all payment methods

  Future<PaymentMethod> getPaymentMethodById(String idPMethod) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.paymentMethods)
        .doc(idPMethod)
        .get();

    return PaymentMethod.fromJson(querySnapshot.data() as Map<String, dynamic>, id: querySnapshot.id);
  }
}