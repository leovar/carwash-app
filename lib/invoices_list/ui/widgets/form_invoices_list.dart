import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoices_list/model/invoice_list_model.dart';
import 'package:car_wash_app/invoices_list/ui/widgets/filter_fields_widget.dart';
import 'package:car_wash_app/invoices_list/ui/widgets/item_invoices_list.dart';
import 'package:car_wash_app/invoices_list/ui/widgets/total_filter_invoices_widget.dart';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/widgets/gradient_back.dart';
import 'package:car_wash_app/widgets/info_header_container.dart';
import 'package:car_wash_app/widgets/keys.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
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

  ///Filter Keys
  final _textPlaca = TextEditingController();
  final _textConsecutive = TextEditingController();
  var _dateFilterInit = DateTime(DateTime.now().year, DateTime.now().month, 1);
  var _dateFilterFinal = DateTime.now();
  User _operatorFilter = User();
  double _totalPriceFilters = 0.0;
  String _productTypeSelected = '';


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
    return StreamBuilder(
      stream: _blocInvoice.invoicesListByMonthStream(
        widget.locationReference,
        _dateFilterInit,
        _dateFilterFinal,
        _textPlaca.text,
        _operatorFilter.name??'',
        _textConsecutive.text,
      ),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return _containerList(snapshot);
      },
    );
  }

  Widget _containerList(AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        _listInvoices = [];
        break;
      default:
        _listInvoices = _blocInvoice.buildInvoicesListByMonth(snapshot.data.documents);
        _listInvoices.sort((a, b) => b.consecutive.compareTo(a.consecutive));
        _countAmountPerDayMonth();
    }

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
                    openFilters: _callBackOpenFilter,
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
          index: index,
          updateDate: true,
          isAdmon: _showInfoAmounts,
          closeInvoice: _closeInvoiceCallback,
        );
      },
    );
  }

  Widget _infoAmounts() {
    final formatter = NumberFormat("#,###");
    return Column(
      children: <Widget>[
        Container(
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
        ),
        Container(
          margin: EdgeInsets.only(left: 22),
          padding: EdgeInsets.only(top: 5),
          alignment: Alignment.centerLeft,
          height: 25,
          child: Text(
            'Total Filtro: \$${formatter.format(_totalPriceFilters)}',
            style: TextStyle(
              fontFamily: "Lato",
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Color(0xFF27AEBB),
            ),
          ),
        )
      ],
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
    _totalPriceFilters = 0.0;
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

        _totalPriceFilters = _totalPriceFilters + invoice.totalPrice;
      });
    }
  }

  void _callBackOpenFilter() {
    Alert(
      context: context,
      title: 'Filtros',
      style: MessagesUtils.alertStyle,
      content: FilterFieldsWidget(
        placaController: _textPlaca,
        consecutiveController: _textConsecutive,
        dateInit: _dateFilterInit,
        dateFinal: _dateFilterFinal,
        operatorSelected: _operatorFilter,
        productTypeSelected: _productTypeSelected,
        selectOperator: _callBackSelectOperatorFilter,
        selectDateInit: _setDateInitFilter,
        selectDateFinal: _setDateFinalFilter,
        selectProductType: _callBackSelectProductTYpe,
      ),
      buttons: [
        DialogButton(
          color: Theme.of(context).accentColor,
          child: Text(
            'ACEPTAR',
            style: Theme.of(context).textTheme.button,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {

            });
          },
        )
      ],
    ).show();
  }

  void _callBackSelectOperatorFilter(User operatorSelected) {
    _operatorFilter = operatorSelected;
  }

  void _setDateInitFilter(DateTime dateInit) {
    _dateFilterInit = dateInit;
  }

  void _setDateFinalFilter(DateTime dateFinal) {
    _dateFilterFinal = dateFinal;
  }

  void _callBackSelectProductTYpe(String selectProductType) {
    if(selectProductType == 'Typo de Servicio..')
      _productTypeSelected = '';
    else
      _productTypeSelected = selectProductType;
  }

  void _closeInvoiceCallback(Invoice _invoiceClose) {
    if (_invoiceClose.userOperatorName.isEmpty) {
      MessagesUtils.showAlert(context: context, title: 'Debe seleccionar el Operador de lavado para cerrar').show();
    } else {
      Alert(
        context: context,
        type: AlertType.info,
        title: 'Esta seguro que desea cerrar la factura !',
        style: MessagesUtils.alertStyle,
        buttons: [
          DialogButton(
            color: Theme.of(context).accentColor,
            child: Text(
              'ACEPTAR',
              style: Theme.of(context).textTheme.button,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _closeInvoice(_invoiceClose);
            },
          ),
          DialogButton(
            color: Theme.of(context).accentColor,
            child: Text(
              'CANCELAR',
              style: Theme.of(context).textTheme.button,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {

              });
            },
          ),
        ],
      ).show();
    }
  }

  void _closeInvoice(Invoice invoiceToClose) async {
    MessagesUtils.showAlertWithLoading(context: context, title: 'Guardando..').show();
    Invoice invoice = Invoice.copyWith(
      origin: invoiceToClose,
      closedDate: Timestamp.now(),
      invoiceClosed: true,

    );
    await _blocInvoice.saveInvoice(invoice);
    if (invoiceToClose.phoneNumber.isNotEmpty) {
      String message = "Spa CarWash Movil -- Estimado cliente. Le informamos que el servicio de lavado de su vehículo, realizado en Spa Car Wash Móvil, ha terminado y está listo para ser entregado. Lo esperamos en nuestras instalaciones.";
      List<String> recipents = [invoiceToClose.phoneNumber];
      _sendSMS(message, recipents);
    }

    Navigator.pop(context);
  }

  void _sendSMS(String message, List<String> recipents) async {
    String _result = await FlutterSms
        .sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }
}
