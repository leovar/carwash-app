import 'package:car_wash_app/reports/bloc/bloc_reports.dart';
import 'package:car_wash_app/reports/model/products_card_detail.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class ProductivityUserDetailPage extends StatefulWidget {
  final List<ProductsCardDetail> productsList;

  ProductivityUserDetailPage({Key key, this.productsList});

  @override
  State<StatefulWidget> createState() => _ProductivityUserDetailPage();
}

class _ProductivityUserDetailPage extends State<ProductivityUserDetailPage> {
  BlocReports _blocReports;
  List<ProductsCardDetail> _productsCard;

  @override
  void initState() {
    super.initState();
    if (widget.productsList != null) {
      _productsCard = widget.productsList;
    }
  }

  @override
  Widget build(BuildContext context) {
    _blocReports = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Detalle de servicios",
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
        child: Container(
          color: Colors.white,
        ),
      ),
    );
  }
}
