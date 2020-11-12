import 'package:cloud_firestore/cloud_firestore.dart';

class CardReport {
  final String operatorName;
  final DocumentReference operatorReference;
  final String locationName;
  int countServices;
  double totalPrice;

  CardReport(
      this.operatorName,
      this.operatorReference,
      this.locationName,
      this.countServices,
      this.totalPrice,
      );
}