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

  /// Get Vehicle Reference
  Future<Product> getProductById(String productId) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.products)
        .document(productId)
        .get();

    return Product.fromJson(querySnapshot.data, id: querySnapshot.documentID);
  }

  Future<List<Product>> getAllProducts() async {
    List<Product> productList = <Product>[];
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.products)
        .getDocuments();

    final documents = querySnapshot.documents;
    if (documents.length > 0) {
      documents.forEach((document) {
        Product product = Product.fromJson(document.data, id: document.documentID);
        productList.add(product);
      });
    }
    return productList;
  }
}
