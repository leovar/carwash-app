import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/configuration.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/reports/bloc/bloc_reports.dart';
import 'package:car_wash_app/reports/model/operator_prod_card.dart';
import 'package:car_wash_app/reports/ui/widgets/item_operator_prod_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OperatorsReport extends StatefulWidget {
  final DocumentReference locationReference;
  final Configuration configuration;

  OperatorsReport({Key key, this.locationReference, this.configuration});

  @override
  State<StatefulWidget> createState() => _OperatorsReport();
}

class _OperatorsReport extends State<OperatorsReport> {
  BlocReports _blocReports = BlocReports();
  BlocInvoice _blocInvoice = BlocInvoice();
  var _dateTimeInit = DateTime(DateTime.now().year, DateTime.now().month, 1);
  var _dateTimeFinal = DateTime.now();
  List<OperatorProductivityCard> _listCardReport = [];
  List<Invoice> _listInvoices = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _blocInvoice.dispose();
    _blocReports.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Informe Operadores",
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
    return StreamBuilder(
        stream: _blocReports.productivityReportListStream(
            widget.locationReference, _dateTimeInit, _dateTimeFinal),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return _listOperators(snapshot);
        });
  }

  Widget _listOperators(AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return Center(
          child: CircularProgressIndicator(),
        );
      default:
        _listInvoices =
            _blocReports.buildProductivityReportList(snapshot.data.documents);
        _listCardReport = _processInvoicesOperator(_listInvoices
            .where((f) => !f.cancelledInvoice && f.invoiceClosed)
            .toList());
        _listCardReport.sort((a, b) => a.operatorName.compareTo(b.operatorName));
    }

    return Container(
      padding: EdgeInsets.only(bottom: 17),
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: ListView.builder(
              itemCount: _listCardReport.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return ItemOperatorProductivityDetail(
                  cardReport: _listCardReport[index],
                  configuration: widget.configuration,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Functions
  List<OperatorProductivityCard> _processInvoicesOperator(
      List<Invoice> _listInvoices) {
    List<OperatorProductivityCard> _cardList = [];
    try {
      _listInvoices.forEach((itemInvoice) {
        if (itemInvoice.operatorUsers != null) {
          itemInvoice.operatorUsers.forEach((item) {
            List<Invoice> invoicesPerUser = [];
            double _totalPrice = itemInvoice.totalPrice / itemInvoice.countOperators;
            OperatorProductivityCard cardInfo = _cardList.length > 0
                ? _cardList.firstWhere(
                    (x) =>
                        x.operatorName == item.name,
                    orElse: () => null,
                  )
                : null;

            if (cardInfo == null) {
              invoicesPerUser.add(itemInvoice);
              final newOperatorCard = OperatorProductivityCard(
                item.name,
                item.id,
                itemInvoice.locationName,
                itemInvoice.creationDate.toDate().day,
                itemInvoice.countOperators == 1
                    ? itemInvoice.countProducts +
                    itemInvoice.countAdditionalProducts
                    : 0,
                itemInvoice.countOperators > 1
                    ? itemInvoice.countProducts +
                    itemInvoice.countAdditionalProducts
                    : 0,
                _totalPrice,
                item.operatorCommission,
                (itemInvoice.creationDate.toDate().day == DateTime.now().day ? item.operatorCommission : 0),
                invoicesPerUser,
                (itemInvoice.creationDate.toDate().day == DateTime.now().day ? 1 : 0),
              );
              _cardList.add(newOperatorCard);
            } else {
              cardInfo.countServices = cardInfo.countServices +
                  (itemInvoice.countOperators == 1
                      ? (itemInvoice.countProducts +
                      itemInvoice.countAdditionalProducts)
                      : 0);
              cardInfo.countSharedServices = cardInfo.countSharedServices +
                  (itemInvoice.countOperators > 1
                      ? (itemInvoice.countProducts +
                      itemInvoice.countAdditionalProducts)
                      : 0);
              cardInfo.totalPrice = cardInfo.totalPrice + _totalPrice;
              List<Invoice> listGet = cardInfo.invoicesList;
              listGet.add(itemInvoice);
              int indexData = _cardList.indexOf(cardInfo);
              _cardList[indexData] = cardInfo;
              cardInfo.totalCommissionDay = cardInfo.totalCommissionDay + (itemInvoice.creationDate.toDate().day == DateTime.now().day ? item.operatorCommission : 0);
              cardInfo.totalCommissionMonth = cardInfo.totalCommissionMonth + item.operatorCommission;
              cardInfo.invoicesPerDay = cardInfo.invoicesPerDay + (itemInvoice.creationDate.toDate().day == DateTime.now().day ? 1 : 0);
            }
          });
        }
      });
      return _cardList;
    } catch (_error) {
      print(_error);
      Fluttertoast.showToast(
          msg: "Error generando el informe: $_error",
          toastLength: Toast.LENGTH_LONG);
      return _cardList;
    }
  }
}
