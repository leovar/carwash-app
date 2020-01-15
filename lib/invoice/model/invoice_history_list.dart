import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceHistoryList {
  final Timestamp creationDate;
  final String consecutive;
  final String lastService;
  final double price;

  InvoiceHistoryList(
    this.creationDate,
    this.consecutive,
    this.lastService,
    this.price,
  );
}
