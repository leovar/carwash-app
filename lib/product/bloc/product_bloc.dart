import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/product/repository/poduct_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class ProductBloc implements Bloc {

  final _productRepository = ProductRepository();

  Stream<QuerySnapshot> get allProductsStream => _productRepository.getListProductsStream();
  List<Product> buildAllProduct(List<DocumentSnapshot> productsListSnapshot) => _productRepository.buildProducts(productsListSnapshot);

  Stream<QuerySnapshot> productsByLocationStream(String idLocation, int uidVehicleType) => _productRepository.getListProductsByLocationStream(idLocation, uidVehicleType);
  List<Product> buildProductByLocation(List<DocumentSnapshot> productsListSnapshot) => _productRepository.buildProductsByLocation(productsListSnapshot);

  void updateProduct(Product product) async {
    return _productRepository.updateProduct(product);
  }

  Future<Product> getProductById(String productId) {
    return _productRepository.getProductById(productId);
  }


  @override
  void dispose() {
  }
}