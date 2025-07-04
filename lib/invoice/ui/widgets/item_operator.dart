import 'package:car_wash_app/user/model/sysUser.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:flutter/material.dart';

class ItemOperator extends StatefulWidget {
  final Function(List<SysUser>) operatorListCallback;
  final List<SysUser> operatorList;
  final int index;
  final bool editForm;
  final bool closedInvoice;
  final bool fromCompleteInvoice;

  ItemOperator(this.operatorListCallback, this.operatorList, this.index,
      this.editForm, this.closedInvoice, this.fromCompleteInvoice);

  @override
  State<StatefulWidget> createState() => _ItemOperator();
}

class _ItemOperator extends State<ItemOperator> {
  int _countOppSelected = 0;

  @override
  Widget build(BuildContext context) {
    _countOppSelected = widget.operatorList.where((u) => (u.isSelected??false)).toList().length;
    return InkWell(
      splashColor: Colors.white,
      onTap: (!widget.closedInvoice && ((_countOppSelected > 0 && !widget.fromCompleteInvoice) || (widget.fromCompleteInvoice)))
          ? () {
              setState(() {
                if (widget.operatorList[widget.index].isSelected??false) {
                  List<SysUser> selected = widget.operatorList.where((u) => (u.isSelected??false)).toList();
                  if (!widget.editForm && selected.length == 1)
                    MessagesUtils.showAlert(context: context, title: 'No se pueden eliminar todos los operadores').show();
                  else
                    widget.operatorList[widget.index].isSelected = false;
                } else {
                  widget.operatorList[widget.index].isSelected = true;
                }
                widget.operatorListCallback(widget.operatorList);
              });
            }
          : null,
      child: itemDecoration(widget.operatorList[widget.index]),
    );
  }

  Widget itemDecoration(SysUser _itemUser) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: 70.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: (_itemUser.isSelected??false) ? Color(0xFFF1F1F1) : Colors.white,
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
              child: (_itemUser.isSelected??false)
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
