import 'package:car_wash_app/invoice/model/invoice.dart';

class CardReport {
  final String operatorName;
  final String operatorId;
  final String locationName;
  int countServices;
  int countSharedServices;
  double totalPrice;
  List<Invoice> invoicesList;

  CardReport(
      this.operatorName,
      this.operatorId,
      this.locationName,
      this.countServices,
      this.countSharedServices,
      this.totalPrice,
      this.invoicesList,
      );
}