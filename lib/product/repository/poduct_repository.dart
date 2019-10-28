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
  List<Product> buildProducts(List<DocumentSnapshot> productListSnapshot){
    List<Product> productList = <Product>[];
    productListSnapshot.forEach((p) {
      Product loc = Product.fromJson(p.data, id: p.documentID);
      productList.add(loc);
    });
    return productList;
  }
}