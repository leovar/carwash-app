import 'package:car_wash_app/invoice/ui/screens/operators_invoice_page.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FieldsOperators extends StatefulWidget {
  final Function(List<User>) callbackOperatorsList;
  final List<User> operatorsListCallback;
  final bool enableForm;
  final int selectedOperatorsCount;
  final bool editForm;
  final bool closedInvoice;
  final String idLocation;

  FieldsOperators({
    Key key,
    this.callbackOperatorsList,
    this.operatorsListCallback,
    this.enableForm,
    this.selectedOperatorsCount,
    this.editForm,
    this.closedInvoice,
    this.idLocation,
  });

  @override
  State<StatefulWidget> createState() => _FieldsOperators();
}

class _FieldsOperators extends State<FieldsOperators> {
  List<User> listUsers = <User>[];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Flexible(
                flex: 4,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(
                        '${widget.selectedOperatorsCount} operadores agregados',
                        style: TextStyle(
                          fontFamily: "Lato",
                          decoration: TextDecoration.none,
                          color: Theme.of(context).accentColor,
                          fontSize: 17,
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
                  margin: EdgeInsets.only(right: 4),
                  child: ButtonTheme(
                    minWidth: 84,
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: BorderSide(
                          color: Theme.of(context).accentColor,
                        ),
                      ),
                      color: Theme.of(context).accentColor,
                      onPressed: (widget.enableForm || !widget.editForm) ? () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OperatorsInvoicePage(
                                  callbackSetOperatorsList: widget.callbackOperatorsList,
                                  usersListCallback: widget.operatorsListCallback,
                                  editForm: widget.editForm,
                                  idLocation: widget.idLocation,
                                  closedInvoice: widget.closedInvoice,
                                  fromCompleteInvoice: false,
                              ),
                            ),
                        );
                      } : null,
                      textColor: Colors.white,
                      child: Text(
                        'ver'.toUpperCase(),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ],
    );
  }
}
