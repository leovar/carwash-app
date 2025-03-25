import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/ui/screens/operators_invoice_page.dart';
import 'package:car_wash_app/user/model/sysUser.dart';
import 'package:flutter/material.dart';

class FieldsOperators extends StatefulWidget {
  final Function(List<SysUser>) callbackOperatorsList;
  final List<SysUser> operatorsListCallback;
  final bool enableForm;
  final int selectedOperatorsCount;
  final bool editForm;
  final bool closedInvoice;
  final String idLocation;
  final Invoice invoice;

  FieldsOperators({
    Key? key,
    required this.callbackOperatorsList,
    required this.operatorsListCallback,
    required this.enableForm,
    required this.selectedOperatorsCount,
    required this.editForm,
    required this.closedInvoice,
    required this.idLocation,
    required this.invoice,
  });

  @override
  State<StatefulWidget> createState() => _FieldsOperators();
}

class _FieldsOperators extends State<FieldsOperators> {
  List<SysUser> listUsers = <SysUser>[];

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
                          color: Theme.of(context).colorScheme.secondary,
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
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Colors.white,
                      ),
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
                                  invoice: widget.invoice,
                                  callbackFinishInvoice: () {  },
                              ),
                            ),
                        );
                      } : null,
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
