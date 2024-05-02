import 'package:car_wash_app/invoice/model/invoice.dart';

class EarningsCardDetail {
  final String locationName;
  int countServices;
  double totalPrice;
  List<Invoice> invoicesList;

  EarningsCardDetail(
      this.locationName,
      this.countServices,
      this.totalPrice,
      this.invoicesList,
      );
}