import 'package:car_wash_app/product/model/product.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemProduct extends StatefulWidget {
  final Function(List<Product>) productListCallback;
  final List<Product> productList;
  final int index;
  final bool editForm;

  ItemProduct(this.productListCallback, this.productList, this.index, this.editForm);

  @override
  State<StatefulWidget> createState() => _ItemProduct();
}

class _ItemProduct extends State<ItemProduct> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.white,
      onTap: widget.editForm ? () {
        setState(() {
          if (widget.productList[widget.index].isSelected) {
            widget.productList[widget.index].isSelected = false;
          } else {
            widget.productList[widget.index].isSelected = true;
          }
          widget.productListCallback(widget.productList);
        });
      } : null,
      child: itemDecoration(widget.productList[widget.index]),
    );
  }

  Widget itemDecoration(Product _itemProduct) {
    final formatter = NumberFormat("#,###");
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 70.0
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: _itemProduct.isSelected ? Color(0xFFF1F1F1) : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFD8D8D8),
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10, right: 15),
              width: 30,
              child: _itemProduct.isSelected
                  ? Icon(
                Icons.check,
                color: Color(0xFF59B258),
                size: 35,
              )
                  : null,
            ),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      _itemProduct.productName,
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        color: Color(0xFFAEAEAE),
                        fontSize: 21,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(top: 4, bottom: 4),
                      child: Text(
                        '\$${formatter.format(_itemProduct.price)}',
                        style: TextStyle(
                          fontFamily: "Lato",
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
