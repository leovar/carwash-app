import 'package:car_wash_app/reports/model/earnings_card_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemEarningCard extends StatefulWidget {
  final EarningsCardDetail cardDetail;

  ItemEarningCard({
    Key? key,
    required this.cardDetail,
  });

  @override
  State<StatefulWidget> createState() => _ItemEarningCard();
}

class _ItemEarningCard extends State<ItemEarningCard> {
  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###");
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 89,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Card(
          color: Colors.white,
          elevation: 5,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                margin: EdgeInsets.only(left: 8,),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.cardDetail.locationName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontFamily: "Lato",
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Flexible(
                    flex: 4,
                    child: Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.only(left: 8, top: 8,),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Flexible(
                                  child: Text(
                                    'Total de venta',
                                    style: TextStyle(
                                      color: Theme.of(context).cardColor,
                                      fontFamily: "Lato",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15.0,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Flexible(
                                  child: Text(
                                    '\$${formatter.format(widget.cardDetail.totalPrice)}',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontFamily: "Lato",
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.only(top: 8,),
                      child: Column(
                        children: [
                          Text(
                            'Total de servicios',
                            style: TextStyle(
                              color: Theme.of(context).cardColor,
                              fontFamily: "Lato",
                              fontWeight: FontWeight.bold,
                              fontSize: 15.0,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            widget.cardDetail.countServices.toString(),
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontFamily: "Lato",
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}