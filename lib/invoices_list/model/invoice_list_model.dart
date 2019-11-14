import 'package:equatable/equatable.dart';

class InvoiceListModel extends Equatable {
  final String id;
  String placa;
  String coordinator;
  String operator;
  final int consec;
  final double totalPrice;
  String vehicleTypeUid;

  InvoiceListModel({
    this.id,
    this.placa,
    this.coordinator,
    this.operator,
    this.consec,
    this.totalPrice,
    this.vehicleTypeUid,
  });

  @override
  List<Object> get props => [
    id,
    placa,
    coordinator,
    operator,
    consec,
    totalPrice,
    vehicleTypeUid,
  ];
}
