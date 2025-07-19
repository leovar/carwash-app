import 'package:car_wash_app/product/bloc/product_bloc.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/product/ui/screens/product_admin_page.dart';
import 'package:car_wash_app/product/ui/widgets/item_products_admin_list.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../widgets/keys.dart';

class ProductListAdminPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProductListAdminPage();
}

class _ProductListAdminPage extends State<ProductListAdminPage> {
  late ProductBloc _productBloc;
  List<Product> _productList = <Product>[];
  String _companyId = '';

  @override
  Widget build(BuildContext context) {
    _productBloc = BlocProvider.of(context);
    this._getPreferences();
    if (_companyId.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            iconSize: 30,
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Servicios",
            style: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            iconSize: 30,
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Servicios",
            style: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 24,
            ),
          ),
          backgroundColor: Colors.white,
        ),
        body: SafeArea(
          child: _containerBody(),
        ),
      );
    }
  }

  Widget _containerBody() {
    return Container(
      padding: EdgeInsets.only(bottom: 17),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _listProducts(),
          _buttonNewProduct(),
        ],
      ),
    );
  }

  Widget _listProducts() {
    return StreamBuilder(
      stream: _productBloc.allProductsStream(_companyId),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return _getDataListProducts(snapshot);
        }
      },
    );
  }

  Widget _getDataListProducts(AsyncSnapshot snapshot) {
    _productList = _productBloc.buildAllProduct(snapshot.data.docs);
    _productList.sort((a, b) {
      int result = (a.vehicleTypeUid??0).compareTo(b.vehicleTypeUid??0);
      if (result == 0) {
        result = (a.productName??'').compareTo(b.productName??'');
      }
      return result;
    });
    return Flexible(
      child: ListView.builder(
        itemCount: _productList.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return ItemProductAdminList(_selectProductList, _productList, index, _companyId);
        },
      ),
    );
  }

  Widget _buttonNewProduct() {
    return Container(
      height: 60,
      margin: EdgeInsets.only(top: 8,),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
            backgroundColor: Color(0xFF59B258),
          ),
          child: Text(
            "Nuevo Servicio",
            style: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 19,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return BlocProvider(
                    bloc: ProductBloc(),
                    child: ProductAdminPage(companyId: _companyId,),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _selectProductList(Product selectedProduct) {}

  Future<void> _getPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (_companyId.isEmpty) {
      setState(() {
        _companyId = pref.getString(Keys.companyId) ?? '';
      });
    }
  }
}
