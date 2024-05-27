import 'package:car_wash_app/invoice/model/invoice.dart';

class OperatorProductivityCard {
  final String operatorName;
  final String operatorId;
  final String locationName;
  final int currentDay;
  int countServices;
  int countSharedServices;
  double totalPrice;
  double totalCommissionMonth;
  double totalCommissionDay;
  List<Invoice> invoicesList;
  int invoicesPerDay;


  OperatorProductivityCard(
      this.operatorName,
      this.operatorId,
      this.locationName,
      this.currentDay,
      this.countServices,
      this.countSharedServices,
      this.totalPrice,
      this.totalCommissionMonth,
      this.totalCommissionDay,
      this.invoicesList,
      this.invoicesPerDay,
      );
}