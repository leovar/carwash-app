import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
      Product loc = Product.fromJson(p.data() as Map<String, dynamic>, id: p.id);
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
                _db.doc('${FirestoreCollections.locations}/$idLocation'))
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
      Product loc = Product.fromJson(p.data() as Map<String, dynamic>, id: p.id);
      productList.add(loc);
    });
    return productList;
  }

  void updateProduct(Product product) async {
    DocumentReference ref =
        _db.collection(FirestoreCollections.products).doc(product.id);
    return await ref.set(product.toJson(), SetOptions(merge: true));
  }

  /// Get Vehicle Reference
  Future<Product> getProductById(String productId) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.products)
        .doc(productId)
        .get();

    return Product.fromJson(querySnapshot.data() as Map<String, dynamic>, id: querySnapshot.id);
  }

  Future<List<Product>> getAllProducts() async {
    List<Product> productList = <Product>[];
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.products)
        .get();

    final documents = querySnapshot.docs;
    if (documents.length > 0) {
      documents.forEach((document) {
        Product product = Product.fromJson(document.data(), id: document.id);
        productList.add(product);
      });
    }
    return productList;
  }
}
