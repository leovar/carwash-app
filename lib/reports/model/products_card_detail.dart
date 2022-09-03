class ProductsCardDetail {
  //-------- counts -----
  int countSimpleServices;
  int countSpecialServices;
  int countSimpleAuto;
  int countSpecialAuto;
  int countSimpleVan;
  int countSpecialVan;
  int countSimpleMoto;
  int countSpecialMoto;
  int countSimpleBicycle;
  int countSpecialBicycle;

  //-------- totals -----
  double totalSimpleValue;
  double totalSpecialValue;
  double totalSimpleAuto;
  double totalSpecialAuto;
  double totalSimpleVan;
  double totalSpecialVal;
  double totalSimpleMoto;
  double totalSpecialMoto;
  double totalSimpleBicycle;
  double totalSpecialBicycle;

  //-------- commissions -----
  double commissionSimpleAuto;
  double commissionSpecialAuto;
  double commissionSimpleVan;
  double commissionSpecialVan;
  double commissionSimpleMoto;
  double commissionSpecialMoto;
  double commissionSimpleBicycle;
  double commissionSpecialBicycle;
  double totalCommission;
  double totalPrice;
  String dateServices;

  ProductsCardDetail(
      this.countSimpleServices,
      this.countSpecialServices,
      this.countSimpleAuto,
      this.countSpecialAuto,
      this.countSimpleVan,
      this.countSpecialVan,
      this.countSimpleMoto,
      this.countSpecialMoto,
      this.countSimpleBicycle,
      this.countSpecialBicycle,
      this.totalSimpleValue,
      this.totalSpecialValue,
      this.totalSimpleAuto,
      this.totalSpecialAuto,
      this.totalSimpleVan,
      this.totalSpecialVal,
      this.totalSimpleMoto,
      this.totalSpecialMoto,
      this.totalSimpleBicycle,
      this.totalSpecialBicycle,
      this.commissionSimpleAuto,
      this.commissionSpecialAuto,
      this.commissionSimpleVan,
      this.commissionSpecialVan,
      this.commissionSimpleMoto,
      this.commissionSpecialMoto,
      this.commissionSimpleBicycle,
      this.commissionSpecialBicycle,
      this.totalCommission,
      this.totalPrice,
      this.dateServices);
}
