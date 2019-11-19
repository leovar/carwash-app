import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductRepository {
  final Firestore _db = Firestore.instance;

  Stream<QuerySnapshot> getListProductsStream() {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.products)
        //.where(FirestoreCollections.locations, arrayContains: )
        .snapshots();
    return querySnapshot;
  }

  List<Product> buildProducts(List<DocumentSnapshot> productListSnapshot) {
    List<Product> productList = <Product>[];
    productListSnapshot.forEach((p) {
      Product loc = Product.fromJson(p.data, id: p.documentID);
      productList.add(loc);
    });
    return productList;
  }

  Stream<QuerySnapshot> getListProductsByLocationStream(
      String idLocation, int uidVehicleType) {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.products)
        .where(FirestoreCollections.locations,
            arrayContains:
                _db.document('${FirestoreCollections.locations}/$idLocation'))
        .where(FirestoreCollections.productFieldUidVehicleType,
            isEqualTo: uidVehicleType)
        .where(FirestoreCollections.productFieldProductActive, isEqualTo: true)
        .snapshots();
    return querySnapshot;
  }

  List<Product> buildProductsByLocation(
      List<DocumentSnapshot> productListSnapshot) {
    List<Product> productList = <Product>[];
    productListSnapshot.forEach((p) {
      Product loc = Product.fromJson(p.data, id: p.documentID);
      productList.add(loc);
    });
    return productList;
  }

  void updateProduct(Product product) async {
    DocumentReference ref =
        _db.collection(FirestoreCollections.products).document(product.id);
    return await ref.setData(product.toJson(), merge: true);
  }
}
