import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CardReport {
  final String operatorName;
  final DocumentReference operatorReference;
  final String locationName;
  int countServices;
  double totalPrice;
  List<Invoice> invoicesList;

  CardReport(
      this.operatorName,
      this.operatorReference,
      this.locationName,
      this.countServices,
      this.totalPrice,
      this.invoicesList,
      );
}