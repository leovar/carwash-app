import 'package:cloud_firestore/cloud_firestore.dart';

class InvoiceHistoryList {
  final Timestamp creationDate;
  final String consecutive;
  final String lastService;

  InvoiceHistoryList(
    this.creationDate,
    this.consecutive,
    this.lastService,
  );
}
