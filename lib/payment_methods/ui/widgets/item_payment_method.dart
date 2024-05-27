import 'package:car_wash_app/payment_methods/bloc/bloc_payment_method.dart';
import 'package:car_wash_app/payment_methods/model/payment_methods.dart';
import 'package:car_wash_app/payment_methods/ui/screens/create_payment_method_admin_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class ItemPaymentMethodAdmin extends StatefulWidget {
  final List<PaymentMethod> paymentMethodList;
  final int index;

  ItemPaymentMethodAdmin(this.paymentMethodList, this.index);

  @override
  State<StatefulWidget> createState() => _ItemPaymentMethodAdmin();
}

class _ItemPaymentMethodAdmin extends State<ItemPaymentMethodAdmin> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.white,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return BlocProvider(
                bloc: BlocPaymentMethod(),
                child: CreatePaymentMethodAdminPage(
                  currentPaymentMethod: widget.paymentMethodList[widget.index],
                ),
              );
            },
          ),
        );
      },
      child: itemDecoration(widget.paymentMethodList[widget.index]),
    );
  }

  Widget itemDecoration(PaymentMethod _itemPaymentMethod) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 70.0),
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
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Flexible(
              child: Container(
                margin: EdgeInsets.only(left: 20),
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //direction: Axis.vertical,
                        children: <Widget>[
                          Flexible(
                            child: Text(
                              _itemPaymentMethod.name,
                              style: TextStyle(
                                fontFamily: "Lato",
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              height: 25,
              margin: EdgeInsets.only(right: 8.0),
              child: _itemPaymentMethod.active
                  ? Icon(
                Icons.check,
                color: Theme.of(context).primaryColor,
              )
                  : Icon(
                Icons.block,
                color: Colors.red,
              ),
            )
          ],
        ),
      ),
    );
  }
}