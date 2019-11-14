import 'package:car_wash_app/invoice/model/additional_product.dart';
import 'package:car_wash_app/invoice/ui/screens/additional_products_page.dart';
import 'package:car_wash_app/invoice/ui/widgets/item_product.dart';
import 'package:car_wash_app/product/bloc/product_bloc.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:flutter/material.dart';

class ProductsInvoicePage extends StatefulWidget {
  Function(List<Product>) callbackSetProductsList;
  Function(List<AdditionalProduct>) cbAdditionalProducts;
  List<Product> productListCallback;
  List<AdditionalProduct> additionalProductListCb;
  final vehicleTypeSelect;

  ProductsInvoicePage(
      {Key key,
      this.callbackSetProductsList,
      this.productListCallback,
      this.cbAdditionalProducts,
      this.additionalProductListCb,
      this.vehicleTypeSelect});

  @override
  State<StatefulWidget> createState() {
    return _ProductsInvoicePage();
  }
}

class _ProductsInvoicePage extends State<ProductsInvoicePage> {
  final _productBloc = ProductBloc();

  @override
  Widget build(BuildContext context) {
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
      body: getProducts(),
    );
  }

  Widget getProducts() {
    return StreamBuilder(
      stream: _productBloc.productsStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return listProducts(snapshot);
        }
      },
    );
  }

  Widget listProducts(AsyncSnapshot snapshot) {
    List<Product> getProductList = _productBloc.buildProduct(snapshot.data.documents);
    List<Product> productGet = getProductList;
    if (widget.productListCallback.length > 0) {
      widget.productListCallback.forEach((f) {
        if (f.isSelected) {
          productGet[productGet.indexWhere((p) => p.id == f.id)].isSelected =
              true;
        }
      });
      widget.productListCallback = productGet;
    }
    widget.productListCallback = productGet;

    return Column(
      children: <Widget>[
        Container(
          height: 65,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  width: widget.vehicleTypeSelect.withImage,
                  margin: EdgeInsets.only(right: 5),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image:
                            AssetImage(widget.vehicleTypeSelect.imageSelected)),
                  ),
                ),
                Flexible(
                  child: Text(
                    widget.vehicleTypeSelect.text,
                    style: TextStyle(
                      fontFamily: "Lato",
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF59B258),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Flexible(
          child: ListView.builder(
            itemCount: widget.productListCallback.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              return ItemProduct(widget.callbackSetProductsList,
                  widget.productListCallback, index);
            },
          ),
        ),
        Container(
          height: 100,
          child: Align(
            alignment: Alignment.center,
            child: RaisedButton(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
              color: Color(0xFF59B258),
              child: Text(
                "Otros Servicios",
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
                    builder: (context) => AdditionalProductPage(
                      setCbAdditionalProducts: widget.cbAdditionalProducts,
                      additionalProductsList: widget.additionalProductListCb,
                    ),
                  ),
                );
              },
            ),
          ),
        )
      ],
    );
  }
}
