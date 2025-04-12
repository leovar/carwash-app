import 'package:car_wash_app/invoice/model/additional_product.dart';
import 'package:car_wash_app/invoice/model/header_services.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/ui/screens/additional_products_page.dart';
import 'package:car_wash_app/invoice/ui/widgets/item_product.dart';
import 'package:car_wash_app/product/bloc/product_bloc.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:flutter/material.dart';

class ProductsInvoicePage extends StatefulWidget {
  final Function(List<Product>) callbackSetProductsList;
  final Function(List<AdditionalProduct>) cbAdditionalProducts;
  List<Product> productListCallback;
  final List<AdditionalProduct> additionalProductListCb;
  final HeaderServices vehicleTypeSelect;
  final String idLocation;
  final bool editForm;
  final Invoice? invoice;

  ProductsInvoicePage({
    Key? key,
    required this.callbackSetProductsList,
    required this.productListCallback,
    required this.cbAdditionalProducts,
    required this.additionalProductListCb,
    required this.vehicleTypeSelect,
    required this.idLocation,
    required this.editForm,
    this.invoice,
  });

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
    if (widget.invoice != null && (widget.invoice?.invoiceClosed??false)) {
      List<Product> productsList = [];
      widget.productListCallback.forEach((prod) {
        Product prodSelected = Product.copyProductInvoiceWith(
          origin: prod,
          isSelected: true,
          price: prod.price,
          ivaPercent: prod.ivaPercent,
        );
        productsList.add(prodSelected);
      });
      widget.productListCallback = productsList;
      return _showListProducts();
    } else {
      return StreamBuilder(
        stream: _productBloc.productsByLocationStream(
            widget.idLocation, widget.vehicleTypeSelect.uid),
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
  }

  Widget listProducts(AsyncSnapshot snapshot) {
    List<Product> productsList = _productBloc.buildProductByLocation(snapshot.data.docs);
    List<Product> productGet = <Product>[];
    productsList.forEach((prod) {
      Product proFindSelect = widget.productListCallback.firstWhere(
          (d) => d.id == prod.id && (d.isSelected??false),
          orElse: () => new Product());
      if (proFindSelect.id == null) {
        productGet.add(prod);
      } else {
        Product prodSelected = Product.copyProductInvoiceWith(
          origin: prod,
          isSelected: true,
          price: proFindSelect.price,
          ivaPercent: proFindSelect.ivaPercent,
        );
        productGet.add(prodSelected);
      }
    });
    widget.productListCallback = productGet;

    return _showListProducts();
  }

  Widget _showListProducts() {
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
                  widget.productListCallback, index, widget.editForm);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                height: 100,
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                      backgroundColor: Color(0xFF59B258),
                    ),
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
                            setCbAdditionalProducts:
                            widget.cbAdditionalProducts,
                            additionalProductsList:
                            widget.additionalProductListCb,
                            editForm: widget.editForm,
                            vehicleTypeSelect: widget.vehicleTypeSelect,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Flexible(
              child: Container(
                height: 100,
                child: Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                      backgroundColor: Color(0xFF59B258),
                    ),
                    child: Text(
                      "Aceptar",
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 19,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
