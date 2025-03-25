import 'package:car_wash_app/reports/model/products_card_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemProductivityReportDetail extends StatefulWidget {
  final ProductsCardDetail serviceDetail;
  final int index;

  ItemProductivityReportDetail(this.serviceDetail, this.index);

  @override
  State<StatefulWidget> createState() => _ItemProductivityReportDetail();
}

class _ItemProductivityReportDetail
    extends State<ItemProductivityReportDetail> {
  late ProductsCardDetail _serviceDetail;

  @override
  void initState() {
    super.initState();
    _serviceDetail = widget.serviceDetail;
    }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 110.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: (widget.index % 2 == 0) ? Colors.white : Color(0xFFF1F1F1),
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFD8D8D8),
                width: 1.0,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _itemHeader(),
              _itemBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemHeader() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          flex: 4,
          child: Row(
            children: [
              Flexible(
                child: Container(
                  padding: EdgeInsets.only(left: 12, top: 8),
                  child: Text(
                    _serviceDetail.dateServices,
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
        Flexible(
          flex: 2,
          child: Container(
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(right: 8, top: 8),
            child: Text(
              (_serviceDetail.countSimpleServices +
                          _serviceDetail.countSpecialServices + _serviceDetail.countSharedServices)
                      .toString() +
                  '  Servicios',
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
    );
  }

  Widget _itemBody() {
    final formatterPrice = NumberFormat("#,###");
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Flexible(
          child: Row(
            children: [
              Flexible(
                child: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(top: 8, right: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Container(
                                height: 24,
                              ),
                            ),
                            Flexible(
                              flex: 4,
                              child: Container(
                                height: 24,
                              ),
                            ),
                            Flexible(
                                flex: 2,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Total',
                                      style: TextStyle(
                                        fontFamily: "Lato",
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.0,
                                        color: Color(0xFFAEAEAE),
                                      ),
                                    ),
                                  ],
                                )),
                            Flexible(
                              flex: 2,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    'Comisión',
                                    style: TextStyle(
                                      fontFamily: "Lato",
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.0,
                                      color: Color(0xFFAEAEAE),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: (_serviceDetail.countSimpleAuto > 0),
                        child: Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            _serviceDetail.countSimpleAuto
                                                .toString(),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontFamily: "Lato",
                                              decoration: TextDecoration.none,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 6,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Sencillo Automovil',
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            decoration: TextDecoration.none,
                                            fontSize: 15.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${formatterPrice.format(_serviceDetail.totalSimpleAuto)}',
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${formatterPrice.format(_serviceDetail.commissionSimpleAuto)}',
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (_serviceDetail.countSpecialAuto > 0),
                        child: Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _serviceDetail.countSpecialAuto
                                                .toString(),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontFamily: "Lato",
                                              decoration: TextDecoration.none,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 6,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Especiales Automovil',
                                            style: TextStyle(
                                              fontFamily: "Lato",
                                              decoration: TextDecoration.none,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${formatterPrice.format(_serviceDetail.totalSpecialAuto)}',
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${formatterPrice.format(_serviceDetail.commissionSpecialAuto)}',
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (_serviceDetail.countSimpleVan > 0),
                        child: Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _serviceDetail.countSimpleVan
                                                .toString(),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontFamily: "Lato",
                                              decoration: TextDecoration.none,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 6,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Sencillo Camioneta',
                                            style: TextStyle(
                                              fontFamily: "Lato",
                                              decoration: TextDecoration.none,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${formatterPrice.format(_serviceDetail.totalSimpleVan)}',
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${formatterPrice.format(_serviceDetail.commissionSimpleVan)}',
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (_serviceDetail.countSpecialVan > 0),
                        child: Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _serviceDetail.countSpecialVan
                                                .toString(),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontFamily: "Lato",
                                              decoration: TextDecoration.none,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 6,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Especiales Camioneta',
                                            style: TextStyle(
                                              fontFamily: "Lato",
                                              decoration: TextDecoration.none,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${formatterPrice.format(_serviceDetail.totalSpecialVal)}',
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${formatterPrice.format(_serviceDetail.commissionSpecialVan)}',
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (_serviceDetail.countSimpleMoto > 0),
                        child: Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _serviceDetail.countSimpleMoto
                                                .toString(),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontFamily: "Lato",
                                              decoration: TextDecoration.none,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 6,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Sencillo Moto',
                                            style: TextStyle(
                                              fontFamily: "Lato",
                                              decoration: TextDecoration.none,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${formatterPrice.format(_serviceDetail.totalSimpleMoto)}',
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${formatterPrice.format(_serviceDetail.commissionSimpleMoto)}',
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (_serviceDetail.countSpecialMoto > 0),
                        child: Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _serviceDetail.countSpecialMoto
                                                .toString(),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontFamily: "Lato",
                                              decoration: TextDecoration.none,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 6,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Epeciales Moto',
                                            style: TextStyle(
                                              fontFamily: "Lato",
                                              decoration: TextDecoration.none,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${formatterPrice.format(_serviceDetail.totalSpecialMoto)}',
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${formatterPrice.format(_serviceDetail.commissionSpecialMoto)}',
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: ((_serviceDetail.countSimpleBicycle +
                                _serviceDetail.countSpecialBicycle) >
                            0),
                        child: Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            (_serviceDetail.countSimpleBicycle +
                                                    _serviceDetail
                                                        .countSpecialBicycle)
                                                .toString(),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontFamily: "Lato",
                                              decoration: TextDecoration.none,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 6,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Bicycletas',
                                            style: TextStyle(
                                              fontFamily: "Lato",
                                              decoration: TextDecoration.none,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${formatterPrice.format(_serviceDetail.totalSimpleBicycle + _serviceDetail.totalSpecialBicycle)}',
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${formatterPrice.format(_serviceDetail.commissionSimpleBicycle + _serviceDetail.commissionSpecialBicycle)}',
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: (_serviceDetail.countSharedServices > 0),
                        child: Flexible(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            _serviceDetail.countSharedServices
                                                .toString(),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontFamily: "Lato",
                                              decoration: TextDecoration.none,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    flex: 6,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Servicios Compartidos',
                                            style: TextStyle(
                                              fontFamily: "Lato",
                                              decoration: TextDecoration.none,
                                              fontSize: 15.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${formatterPrice.format(_serviceDetail.totalSharedValue)}',
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 3,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '\$${formatterPrice.format(_serviceDetail.commissionSharedServices)}',
                                          style: TextStyle(
                                            fontFamily: "Lato",
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15.0,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 1,
                              child: Container(
                                height: 24,
                              ),
                            ),
                            Flexible(
                              flex: 4,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: Text(
                                      'Totales',
                                      style: TextStyle(
                                        fontFamily: "Lato",
                                        decoration: TextDecoration.none,
                                        fontSize: 17.0,
                                        color: Color(0xFF59B258),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${formatterPrice.format(_serviceDetail.totalPrice)}',
                                    style: TextStyle(
                                      fontFamily: "Lato",
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.0,
                                      color: Color(0xFF59B258),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 2,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${formatterPrice.format(_serviceDetail.totalCommission)}',
                                    style: TextStyle(
                                      fontFamily: "Lato",
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.0,
                                      color: Color(0xFF59B258),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
