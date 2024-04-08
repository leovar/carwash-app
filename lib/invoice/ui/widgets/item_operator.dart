import 'package:car_wash_app/user/model/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemOperator extends StatefulWidget {
  final Function(List<User>) operatorListCallback;
  final List<User> operatorList;
  final int index;
  final bool editForm;
  final bool closedInvoice;

  ItemOperator(this.operatorListCallback, this.operatorList, this.index, this.editForm, this.closedInvoice);

  @override
  State<StatefulWidget> createState() => _ItemOperator();
}

class _ItemOperator extends State<ItemOperator> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.white,
      onTap: !widget.closedInvoice ? () {
        setState(() {
          if (widget.operatorList[widget.index].isSelected) {
            widget.operatorList[widget.index].isSelected = false;
          } else {
            widget.operatorList[widget.index].isSelected = true;
          }
          widget.operatorListCallback(widget.operatorList);
        });
      } : null,
      child: itemDecoration(widget.operatorList[widget.index]),
    );
  }

  Widget itemDecoration(User _itemUser) {
    return ConstrainedBox(
      constraints: BoxConstraints(
          minHeight: 70.0
      ),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: _itemUser.isSelected ? Color(0xFFF1F1F1) : Colors.white,
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
              child: _itemUser.isSelected
                  ? Icon(
                Icons.check,
                color: Color(0xFF59B258),
                size: 30,
              )
                  : null,
            ),
            Flexible(
              child: Text(
                _itemUser.name,
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  color: Color(0xFFAEAEAE),
                  fontSize: 21,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}