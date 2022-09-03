import 'package:car_wash_app/commission/model/commission.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CommissionRepository {
  final Firestore _db = Firestore.instance;

  Stream<QuerySnapshot> getListCommissionsStream() {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.commissions)
        .snapshots();
    return querySnapshot;
  }

  List<Commission> buildCommissions(List<DocumentSnapshot> commissionListSnapshot) {
    List<Commission> commissionList = <Commission>[];
    commissionListSnapshot.forEach((p) {
      Commission loc = Commission.fromJson(p.data, id: p.documentID);
      commissionList.add(loc);
    });
    return commissionList;
  }

  void updateCommission(Commission commission) async {
    DocumentReference ref =
        _db.collection(FirestoreCollections.commissions).document(commission.id);
    return await ref.setData(commission.toJson(), merge: true);
  }

  Future<List<Commission>> getAllCommissions() async {
    List<Commission> commissionList = <Commission>[];
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.commissions)
        .getDocuments();

    final documents = querySnapshot.documents;
    if (documents.length > 0) {
      documents.forEach((document) {
        Commission commission = Commission.fromJson(document.data, id: document.documentID);
        commissionList.add(commission);
      });
    }
    return commissionList;
  }
}
