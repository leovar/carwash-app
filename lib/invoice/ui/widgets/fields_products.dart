import 'package:car_wash_app/invoice/ui/screens/products_invoice_page.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:flutter/material.dart';

class FieldsProducts extends StatefulWidget {
  Function(List<Product>) callbackProductsList;
  List<Product> productListCallback;
  final vehicleTypeSelect;

  FieldsProducts({Key key, this.callbackProductsList, this.productListCallback, this.vehicleTypeSelect});

  @override
  State<StatefulWidget> createState() {
    return _FieldsProducts();
  }
}

class _FieldsProducts extends State<FieldsProducts> {
  int selectedProductsCount = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(left: 10),
                child: Text(
                  '$selectedProductsCount servicios agregados',
                  style: TextStyle(
                    fontFamily: "Lato",
                    decoration: TextDecoration.none,
                    color: Color(0xFF59B258),
                    fontSize: 17,
                  ),
                ),
              ),
              /*Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    size: 30,
                  ),
                ),
              ),*/
            ],
          ),
          decoration: BoxDecoration(
            color: Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        SizedBox(
          height: 9,
        ),
        Container(
          height: 90,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: <Widget>[
              FloatingActionButton(
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30,
                ),
                backgroundColor: Color(0xFFCCCCCC),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductsInvoicePage(
                        callbackSetProductsList: _setProductList,
                        productListCallback : widget.productListCallback,
                        vehicleTypeSelect: widget.vehicleTypeSelect,
                      ),
                    ),
                  );
                },
                heroTag: null,
              ),
              Container(
                margin: EdgeInsets.only(left: 15),
                child: Text(
                  "Agregar Servicios",
                  style: TextStyle(
                    fontFamily: "Lato",
                    decoration: TextDecoration.none,
                    color: Color(0xFFAEAEAE),
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFD8D8D8),
                width: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _setProductList(List<Product> productListGet) {
    List<Product> listSelected = productListGet.where((f) => f.isSelected == true).toList();
    selectedProductsCount = listSelected.length;
    widget.callbackProductsList(productListGet);
  }
}
