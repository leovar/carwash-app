import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
class Product extends Equatable {
  final String? id;
  final String? productName;
  final double? price;
  final double? ivaPercent;
  final DocumentReference? vehicleType;
  final List<DocumentReference>? locations;
  final bool? productActive;
  final int? vehicleTypeUid;
  bool? isSelected;
  final bool? isAdditional;
  bool? newProduct;
  final String? productType;
  final String? productInvoiceId;
  final Timestamp? dateAdded;
  final int? serviceTime;
  final double? productCommission;
  int? countOperatorsInvoice;
  int? invoiceConsecutive;

  Product({
    this.id,
    this.productName,
    this.price,
    this.ivaPercent,
    this.vehicleType,
    this.locations,
    this.productActive,
    this.vehicleTypeUid,
    this.isSelected,
    this.isAdditional,
    this.newProduct,
    this.productType,
    this.productInvoiceId,
    this.dateAdded,
    this.serviceTime,
    this.productCommission,
    this.countOperatorsInvoice,
    this.invoiceConsecutive,
  });

  factory Product.fromJson(Map<String, dynamic> json, {String? id}) {
    List<DocumentReference> locationsListDb = <DocumentReference>[];
    List locationsList = json['locations']??[];
    locationsList.forEach((drLocation) {
      locationsListDb.add(drLocation);
    });

    return Product(
      id: id,
      productName: json['productName'],
      price: json['price'].toDouble(),
      ivaPercent: json['ivaPercent'].toDouble(),
      vehicleType: json['vehicleType'],
      productActive: json['productActive'],
      vehicleTypeUid: json['vehicleTypeUid'],
      isAdditional: json['isAdditional'],
      locations: locationsListDb,
      isSelected: false,
      productType: json['productType'],
      serviceTime: json['serviceTime'],
    );
  }

  factory Product.fromJsonTemporal(Map<String, dynamic> json) {
    List<DocumentReference> locationsListDb = <DocumentReference>[];
    List locationsList = json['locations'];
    locationsList.forEach((drLocation) {
      locationsListDb.add(drLocation);
    });
    bool additional = json['isAdditional'];
    String newId = json['productId'];
    if (additional ?? false) {
      newId = '';
    }

    return Product(
      id: newId,
      productName: json['productName'],
      price: json['price'].toDouble(),
      ivaPercent: json['ivaPercent'].toDouble(),
      vehicleType: json['vehicleType'],
      productActive: json['productActive'],
      vehicleTypeUid: json['vehicleTypeUid'],
      isAdditional: json['isAdditional'],
      locations: locationsListDb,
      isSelected: false,
      productType: json['productType'],
      serviceTime: json['serviceTime'],
      productCommission: json['productCommission'],
    );
  }

  factory Product.fromJsonProInvoice(Map<String, dynamic> json, {String? id}) {
    List<DocumentReference> locationsListDb = <DocumentReference>[];
    List locationsList = json['locations'];
    locationsList.forEach((drLocation) {
      locationsListDb.add(drLocation);
    });

    return Product(
      id: json['productId'],
      productName: json['productName'],
      price: json['price'].toDouble(),
      ivaPercent: json['ivaPercent'].toDouble(),
      vehicleType: json['vehicleType'],
      productActive: json['productActive'],
      vehicleTypeUid: json['vehicleTypeUid'],
      isAdditional: json['isAdditional'],
      locations: locationsListDb,
      isSelected: true,
      productType: json['productType'],
      productInvoiceId: id,
      serviceTime: json['serviceTime'],
      productCommission: json['productCommission'],
    );
  }

  factory Product.fromJsonProductIntoInvoice(
    Map<dynamic, dynamic> json,
    int? uidVehicleType,
    Timestamp? addDate,
    int? countOperators,
    int? consecutive,
  ) {
    return Product(
      id: json['Id'],
      productName: json['productName'],
      price: (json['price']??0).toDouble(),
      ivaPercent: (json['ivaPercent']??0).toDouble(),
      isAdditional: json['isAdditional'],
      isSelected: true,
      productType: json['productType'],
      vehicleTypeUid: uidVehicleType,
      dateAdded: addDate,
      serviceTime: json['serviceTime'],
      productCommission: json['productCommission'],
      countOperatorsInvoice: countOperators,
      invoiceConsecutive: consecutive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productName': this.productName,
      'price': this.price,
      'ivaPercent': this.ivaPercent,
      'vehicleType': this.vehicleType,
      'locations': this.locations,
      'productActive': this.productActive,
      'vehicleTypeUid': this.vehicleTypeUid,
      'productType': this.productType,
      'serviceTime': this.serviceTime,
    };
  }

  Map<String, dynamic> toJsonInvoiceProduct(
    String? productName,
    double? price,
    double? ivaPercent,
    bool? isAdditional,
    String? productId,
    String? productType,
    int? serviceTime,
    double? commission,
  ) {
    return {
      'productName': productName,
      'price': price,
      'ivaPercent': ivaPercent,
      'isAdditional': isAdditional,
      'Id': productId,
      'productType': productType,
      'serviceTime': serviceTime,
      'productCommission': commission,
    };
  }

  factory Product.copyProductInvoiceWith({
    required Product origin,
    String? id,
    bool? isSelected,
    double? price,
    double? ivaPercent,
    String? productType,
    String? productInvoiceId,
    double? commission,
  }) {
    return Product(
      id: id ?? origin.id,
      productName: origin.productName,
      price: price ?? origin.price,
      ivaPercent: ivaPercent ?? origin.ivaPercent,
      vehicleType: origin.vehicleType,
      locations: origin.locations,
      productActive: origin.productActive,
      vehicleTypeUid: origin.vehicleTypeUid,
      isSelected: isSelected ?? origin.isSelected,
      isAdditional: origin.isAdditional,
      productType: productType ?? origin.productType,
      productInvoiceId: productInvoiceId ?? '',
      serviceTime: origin.serviceTime,
      productCommission: commission ?? origin.productCommission,
    );
  }

  //Copy Product to add product in new invoice at save
  factory Product.copyProductToSaveInvoice({
    String? id,
    String? productName,
    double? price,
    double? ivaPercent,
    bool? isAdditional,
    String? productType,
    int? serviceTime,
    double? commission,
  }) {
    return Product(
      id: id,
      productName: productName,
      price: price,
      ivaPercent: ivaPercent,
      isAdditional: isAdditional ?? true,
      productType: productType,
      serviceTime: serviceTime,
      productCommission: commission,
    );
  }

  @override
  List<Object> get props => [
    id ?? '',
    productName ?? '',
    price ?? 0,
    ivaPercent ?? 0,
    vehicleType ?? FirebaseFirestore.instance.doc("placeholder/empty"),
    locations ?? [],
    productActive ?? false,
    vehicleTypeUid ?? 0,
    isSelected ?? false,
    productType ?? '',
    productInvoiceId ?? '',
    serviceTime ?? 0,
    productCommission ?? 0,
  ];
}
