import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/product/repository/poduct_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class ProductBloc implements Bloc {

  final _productRepository = ProductRepository();

  Stream<QuerySnapshot> get productsStream => _productRepository.getListProductsStream();
  List<Product> buildProduct(List<DocumentSnapshot> productsListSnapshot) => _productRepository.buildProducts(productsListSnapshot);


  @override
  void dispose() {
  }

}