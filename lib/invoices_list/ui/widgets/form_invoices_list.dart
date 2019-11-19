import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoices_list/model/invoice_list_model.dart';
import 'package:car_wash_app/invoices_list/ui/widgets/item_invoices_list.dart';
import 'package:car_wash_app/invoices_list/ui/widgets/total_filter_invoices_widget.dart';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/widgets/gradient_back.dart';
import 'package:car_wash_app/widgets/info_header_container.dart';
import 'package:car_wash_app/widgets/keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class FormInvoicesList extends StatefulWidget {
  final locationReference;

  FormInvoicesList({Key key, this.locationReference});

  @override
  State<StatefulWidget> createState() => _FormInvoicesList();
}

class _FormInvoicesList extends State<FormInvoicesList> {
  BlocInvoice _blocInvoice;
  UserBloc _blocUser = UserBloc();
  List<Invoice> _listInvoices = <Invoice>[];
  List<InvoiceListModel> _listModel = <InvoiceListModel>[];
  User _currentUser;
  bool _showInfoAmounts = false;
  double _totalDay = 0.0;
  double _totalMonth = 0.0;

  @override
  void initState() {
    super.initState();
    _blocUser.getCurrentUser().then((User user) {
      _currentUser = user;
      if (user.isAdministrator) {
        setState(() {
          _showInfoAmounts = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _blocInvoice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _blocInvoice = BlocProvider.of(context);

    this._getPreferences();

    return Stack(
      children: <Widget>[
        GradientBack(),
        _bodyContainer(),
      ],
    );
  }

  Widget _bodyContainer() {
    return Column(
      children: <Widget>[
        InfoHeaderContainer(
          image: 'assets/images/icon_facturas_blanco.png',
          textInfo: 'Facturas',
        ),
        Flexible(
          child: _getInvoices(),
        ),
      ],
    );
  }

  Widget _getInvoices() {
    var date = DateTime(DateTime.now().year, DateTime.now().month, 1);
    return StreamBuilder(
      stream: _blocInvoice.invoicesListByMonthStream(
          widget.locationReference, date),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Container(
              height: 80,
              child: CircularProgressIndicator(),
            );
          default:
            return _containerList(snapshot);
        }
      },
    );
  }

  Widget _containerList(AsyncSnapshot snapshot) {
    _listInvoices =
        _blocInvoice.buildInvoicesListByMonth(snapshot.data.documents);
    _listInvoices.sort((a, b) => b.consecutive.compareTo(a.consecutive));
    _countAmountPerDayMonth();
    _listModel.clear();
    _listInvoices.forEach((invoice) {
      _listModel.add(InvoiceListModel(
        id: invoice.id,
        consec: invoice.consecutive,
        totalPrice: invoice.totalPrice,
        placa: '',
      ));
    });

    return Container(
      margin: EdgeInsets.only(right: 17, left: 17, bottom: 17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.0),
      ),
      child: Column(
        children: <Widget>[
          Visibility(
            visible: _showInfoAmounts,
            child: _infoAmounts(),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.only(
                right: 15,
                left: 15,
                bottom: 15,
              ),
              child: Column(
                children: <Widget>[
                  TotalFilterInvoicesWidget(
                    listInvoices: _listInvoices,
                  ),
                  Expanded(
                    child: _listItems(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listItems() {
    return ListView.builder(
      //shrinkWrap: true,
      itemCount: _listInvoices.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        return ItemInvoicesList(
          listInvoices: _listInvoices,
          listInvoicesModel: _listModel,
          index: index,
          updateDate: true,
        );
      },
    );
  }

  Widget _infoAmounts() {
    final formatter = NumberFormat("#,###");

    return Container(
      margin: EdgeInsets.only(top: 15),
      height: 85,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(7.0)),
            child: Container(
              height: 80,
              width: 150,
              color: Color(0xFFF1F1F1),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Total día',
                      style: TextStyle(
                        fontFamily: "Lato",
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xFF27AEBB),
                      ),
                    ),
                    Text(
                      '\$${formatter.format(_totalDay)}',
                      style: TextStyle(
                        fontFamily: "Lato",
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF59B258),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(7.0)),
            child: Container(
              height: 80,
              width: 150,
              color: Color(0xFFF1F1F1),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Total mes',
                      style: TextStyle(
                        fontFamily: "Lato",
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Color(0xFF27AEBB),
                      ),
                    ),
                    Text(
                '\$${formatter.format(_totalMonth)}',
                      style: TextStyle(
                        fontFamily: "Lato",
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF59B258),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Functions
  void _getPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String userId = pref.getString(Keys.userId);
  }

  void _countAmountPerDayMonth() {
    _totalDay = 0;
    _totalMonth = 0;
    if (_listInvoices.length > 0) {
      _listInvoices.forEach((invoice) {
        DateTime nowMonth =
            new DateTime(DateTime.now().year, DateTime.now().month);
        DateTime nowDay = new DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);
        DateTime dateMonthInvoice = DateTime(invoice.creationDate.toDate().year,
            invoice.creationDate.toDate().month);
        DateTime dateDayInvoice = DateTime(
            invoice.creationDate.toDate().year,
            invoice.creationDate.toDate().month,
            invoice.creationDate.toDate().day);

        if (dateDayInvoice.compareTo(nowDay) == 0) {
          _totalDay = _totalDay + invoice.totalPrice;
        }

        if (nowMonth.compareTo(dateMonthInvoice) == 0) {
          _totalMonth = _totalMonth + invoice.totalPrice;
        }
      });
    }
  }
}
