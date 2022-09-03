import 'package:car_wash_app/reports/model/products_card_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InfoDetailCardProductivity extends StatelessWidget {
  final List<ProductsCardDetail> productivityProducts;
  final double _widthContainer = 300;
  final formatter = new DateFormat('dd-MM-yyyy');

  InfoDetailCardProductivity({Key key, @required this.productivityProducts});

  @override
  Widget build(BuildContext context) {
    List<ProductsCardDetail> _listProducts = productivityProducts;
    //_listProducts.sort((a, b) => b.countServices.compareTo(a.countServices));
    return Container();
    /*
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
              '${_listProducts.length} tipos de servicio',
              style: Theme.of(context).textTheme.display2),
          Container(
            height: 160,
            width: _widthContainer,
            child: ListView.builder(
              itemCount: _listProducts.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                return _itemServices(context, _listProducts[index]);
              },
            ),
          ),
        ],
      ),
    );*/
  }

  /*
  Widget _itemServices(BuildContext context, ProductsCardDetail product) {
    final formatterPrice = NumberFormat("#,###");
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 30),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3),
        width: _widthContainer,
        decoration: BoxDecoration(
          color: Colors.white,
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
              width: 35,
              child: Text(
                product.countServices.toString(),
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  color: Theme.of(context).accentColor,
                  fontSize: 17,
                ),
              ),
            ),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      product.typeProductName,
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(height: 3),
                  Flexible(
                    child: Text(
                      '\$${formatterPrice.format(product.totalPrice)}',
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        color: Theme.of(context).primaryColor,
                        fontSize: 14,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }*/
}
