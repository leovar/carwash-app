import 'package:car_wash_app/product/model/product.dart';
import 'package:flutter/material.dart';

class ItemProduct extends StatefulWidget {
  Function(List<Product>) productListCallback;
  List<Product> productList;
  int index;

  ItemProduct(this.productListCallback, this.productList, this.index);

  @override
  State<StatefulWidget> createState() {
    return _ItemProduct();
  }
}

class _ItemProduct extends State<ItemProduct> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.white,
      onTap: () {
        setState(() {
          if (widget.productList[widget.index].isSelected) {
            widget.productList[widget.index].isSelected = false;
          } else {
            widget.productList[widget.index].isSelected = true;
          }
          widget.productListCallback(widget.productList);
        });
      },
      child: itemDecoration(widget.productList[widget.index]),
    );
  }

  Widget itemDecoration(Product _itemProduct) {
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
              margin: EdgeInsets.only(left: 10),
              width: 30,
              child: _itemProduct.isSelected
                  ? Icon(
                Icons.check,
                color: Color(0xFF59B258),
                size: 35,
              )
                  : null,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 15),
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
            ),
          ],
        ),
      ),
    );
  }
}
