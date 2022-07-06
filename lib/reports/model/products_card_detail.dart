import 'package:cloud_firestore/cloud_firestore.dart';

class ProductsCardDetail {
  int countSimpleServices;
  int countSpecialServices;
  double totalSimpleValue;
  double totalSpecialValue;
  int countSimpleVehicle;
  int countSimpleVan;
  double totalSimpleVehicle;
  double totalSimpleVan;
  double commissionSimpleVehicle;
  double commissionSimpleVan;
  double commissionSpecial;
  double totalCommission;
  double totalPrice;
  String dateServices;

  ProductsCardDetail(
      this.countSimpleServices,
      this.countSpecialServices,
      this.totalSimpleValue,
      this.totalSpecialValue,
      this.countSimpleVehicle,
      this.countSimpleVan,
      this.totalSimpleVehicle,
      this.totalSimpleVan,
      this.commissionSimpleVehicle,
      this.commissionSimpleVan,
      this.commissionSpecial,
      this.totalCommission,
      this.totalPrice,
      this.dateServices,
      );
}