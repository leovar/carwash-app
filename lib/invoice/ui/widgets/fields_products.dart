import 'package:car_wash_app/invoice/model/additional_product.dart';
import 'package:car_wash_app/invoice/model/header_services.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/ui/screens/products_invoice_page.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:flutter/material.dart';

class FieldsProducts extends StatefulWidget {
  final Function(List<Product>) callbackProductsList;
  final Function(List<AdditionalProduct>) callbackAdditionalProdList;
  final List<Product> productListCallback;
  final List<AdditionalProduct> additionalProductListCb;
  final HeaderServices vehicleTypeSelect;
  final bool enableForm;
  final int selectedProductsCount;
  final String idLocation;
  final bool editForm;
  final Invoice? invoice;

  FieldsProducts({
    Key? key,
    required this.callbackProductsList,
    required this.productListCallback,
    required this.callbackAdditionalProdList,
    required this.additionalProductListCb,
    required this.vehicleTypeSelect,
    required this.enableForm,
    required this.selectedProductsCount,
    required this.idLocation,
    required this.editForm,
    required this.invoice,
  });

  @override
  State<StatefulWidget> createState() {
    return _FieldsProducts();
  }
}

class _FieldsProducts extends State<FieldsProducts> {
  List<Product> listProducts = <Product>[];
  List<AdditionalProduct> listAdditionalProducts = <AdditionalProduct>[];

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
                  '${widget.selectedProductsCount} servicios agregados',
                  style: TextStyle(
                    fontFamily: "Lato",
                    decoration: TextDecoration.none,
                    color: Color(0xFF59B258),
                    fontSize: 17,
                  ),
                ),
              ),
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
                backgroundColor: Theme.of(context).colorScheme.secondary,
                onPressed: (widget.enableForm || !widget.editForm)
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductsInvoicePage(
                              callbackSetProductsList:
                                  widget.callbackProductsList,
                              productListCallback: widget.productListCallback,
                              cbAdditionalProducts:
                                  widget.callbackAdditionalProdList,
                              additionalProductListCb:
                                  widget.additionalProductListCb,
                              vehicleTypeSelect: widget.vehicleTypeSelect,
                              idLocation: widget.idLocation,
                              editForm: widget.editForm,
                              invoice: widget.invoice,
                            ),
                          ),
                        );
                      }
                    : null,
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
}
