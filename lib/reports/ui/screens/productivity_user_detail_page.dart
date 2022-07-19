import 'package:car_wash_app/reports/bloc/bloc_reports.dart';
import 'package:car_wash_app/reports/model/products_card_detail.dart';
import 'package:car_wash_app/reports/ui/widgets/item_productivity_report_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:intl/intl.dart';

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
        child: _containerBody(),
      ),
    );
  }

  Widget _containerBody() {
    return Container(
      padding: EdgeInsets.only(bottom: 17),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _listServices(),
          _totalServicesDetails(),
        ],
      ),
    );
  }

  Widget _listServices() {
    return Flexible(
        child: ListView.builder(
            itemCount: _productsCard.length,
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return ItemProductivityReportDetail(_productsCard[index], index);
            },
        ),
    );
  }

  Widget _totalServicesDetails() {
    final formatterPrice = NumberFormat("#,###");
    int _totalServices = 0;
    double _totalValue = 0;
    double _totalCommission = 0;
    _productsCard.forEach((e) {
      _totalServices = _totalServices + (e.countSpecialServices + e.countSimpleServices);
      _totalValue = _totalValue + (e.totalSpecialValue + e.totalSimpleValue);
      _totalCommission = _totalCommission + e.totalCommission;
    });

    return Container(
      height: 96,
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFD8D8D8),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 4,
                child: Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.only(left: 8, top: 8),
                        alignment: Alignment.topLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Text(
                                'Total Servicios',
                                style: TextStyle(
                                  fontFamily: "Lato",
                                  decoration: TextDecoration.none,
                                  fontSize: 17.0,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Flexible(
                              child: Text(
                                'Valor Total',
                                style: TextStyle(
                                  fontFamily: "Lato",
                                  decoration: TextDecoration.none,
                                  fontSize: 17.0,
                                ),
                              ),
                            ),
                            SizedBox(height: 9),
                            Flexible(
                              child: Text(
                                'Comisión Total',
                                style: TextStyle(
                                  fontFamily: "Lato",
                                  decoration: TextDecoration.none,
                                  fontSize: 17.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                flex: 2,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 8, top: 8),
                        child: Text(
                          _totalServices.toString(),
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontWeight: FontWeight.w600,
                            fontSize: 17.0,
                            color: Color(0xFF59B258),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Flexible(
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 8, top: 8),
                        child: Text(
                          '\$${formatterPrice.format(_totalValue)}',
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontWeight: FontWeight.w600,
                            fontSize: 17.0,
                            color: Color(0xFF59B258),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    Flexible(
                      child: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 8, top: 8),
                        child: Text(
                          '\$${formatterPrice.format(_totalCommission)}',
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontWeight: FontWeight.w600,
                            fontSize: 17.0,
                            color: Color(0xFF59B258),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
