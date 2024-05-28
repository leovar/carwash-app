import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/payment_methods/bloc/bloc_payment_method.dart';
import 'package:car_wash_app/payment_methods/model/payment_methods.dart';
import 'package:car_wash_app/invoice/ui/screens/operators_invoice_page.dart';
import 'package:car_wash_app/invoices_list/model/invoice_list_model.dart';
import 'package:car_wash_app/invoices_list/ui/widgets/filter_fields_widget.dart';
import 'package:car_wash_app/invoices_list/ui/widgets/item_invoices_list.dart';
import 'package:car_wash_app/invoices_list/ui/widgets/total_filter_invoices_widget.dart';
import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/widgets/gradient_back.dart';
import 'package:car_wash_app/widgets/info_header_container.dart';
import 'package:car_wash_app/widgets/keys.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:car_wash_app/widgets/select_operator_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_open_whatsapp/flutter_open_whatsapp.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class FormInvoicesList extends StatefulWidget {
  final locationReference;

  FormInvoicesList({Key key, this.locationReference});

  @override
  State<StatefulWidget> createState() => _FormInvoicesList();
}

class _FormInvoicesList extends State<FormInvoicesList> {
  BlocInvoice _blocInvoice;
  final _locationBloc = BlocLocation();
  UserBloc _blocUser = UserBloc();
  BlocPaymentMethod _paymentMethodBloc = BlocPaymentMethod();
  List<Invoice> _listInvoices = <Invoice>[];
  List<InvoiceListModel> _listModel = <InvoiceListModel>[];
  User _currentUser;
  bool _showInfoAmounts = false;
  double _totalDay = 0.0;
  double _totalMonth = 0.0;
  String _idLocation = '';
  Location _location;
  PaymentMethod _selectedPaymentMethod = PaymentMethod(name:'');
  Invoice _invoiceSelected;

  ///Filter Keys
  final _textPlaca = TextEditingController();
  final _textConsecutive = TextEditingController();
  var _dateFilterInit = DateTime(DateTime.now().year, DateTime.now().month, 1);
  var _dateFilterFinal = DateTime.now();
  User _operatorFilter = User(name:'', uid: '', email: '');
  double _totalPriceFilters = 0.0;
  String _productTypeSelected = '';
  PaymentMethod _paymentMethodFilter = PaymentMethod(id: '', name:'');

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
    _locationBloc.dispose();
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
        _operatorFilter.name ?? '',
        _textConsecutive.text,
        _productTypeSelected,
        _paymentMethodFilter.name ?? '',
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
        _listInvoices =
            _blocInvoice.buildInvoicesListByMonth(snapshot.data.documents);
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
          finishInvoice: _finishInvoiceCallback,
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
    if (_idLocation.isEmpty) {
      _idLocation = pref.getString(Keys.idLocation);
      _locationBloc.getLocationById(_idLocation).then((loc) => _location = loc);
    }
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
          _totalDay = _totalDay + (invoice.cancelledInvoice ? 0 : invoice.totalPrice);
        }

        if (nowMonth.compareTo(dateMonthInvoice) == 0) {
          _totalMonth = _totalMonth + (invoice.cancelledInvoice ? 0 : invoice.totalPrice);
        }

        _totalPriceFilters = _totalPriceFilters + (invoice.cancelledInvoice ? 0 : invoice.totalPrice);
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
        paymentMethodSelected: _paymentMethodFilter,
        selectOperator: _callBackSelectOperatorFilter,
        selectDateInit: _setDateInitFilter,
        selectDateFinal: _setDateFinalFilter,
        selectProductType: _callBackSelectProductTYpe,
        selectPaymentMethod: _callBackSelectPaymentMethodFilter,
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
            setState(() {});
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
    if (selectProductType == 'Typo de Servicio..')
      _productTypeSelected = '';
    else
      _productTypeSelected = selectProductType;
  }

  void _callBackSelectPaymentMethodFilter(PaymentMethod paymentMethodSelected) {
    _paymentMethodFilter = paymentMethodSelected;
  }

  void _closeInvoiceCallback(Invoice _invoiceClose) async {
    _invoiceSelected = _invoiceClose;
    if (_invoiceSelected.countOperators > 0) {
      _closeInvoiceMessage();
    }
  }

  void _closeInvoiceMessage() async {
    if ((_invoiceSelected.paymentMethod??'') == '') {
      _selectedPaymentMethod = ((_invoiceSelected.paymentMethod??'') == '' || _invoiceSelected.paymentMethod == null) ? new PaymentMethod(name:'') : await _paymentMethodBloc.getPaymentMethodByName(_invoiceSelected.paymentMethod);
      Alert(
        context: context,
        title: 'Método de pago',
        style: MessagesUtils.alertStyle,
        content: SelectOperatorWidget(
          paymentMethodSelected: _selectedPaymentMethod,
          selectPaymentMethod: _callBackSelectPaymentMethod,
          currentInvoice: _invoiceSelected,
        ),
        buttons: [
          DialogButton(
            color: Theme.of(context).accentColor,
            child: Text(
              'GUARDAR',
              style: Theme.of(context).textTheme.button,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _closeInvoice(true);
            },
          ),
        ],
      ).show();
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
              _closeInvoice(false);
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
              setState(() {});
            },
          ),
        ],
      ).show();
    }
  }

  void _finishInvoiceCallback(Invoice _invoiceToFinish) {
    _invoiceSelected = _invoiceToFinish;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OperatorsInvoicePage(
          callbackSetOperatorsList: _saveOperators,
          usersListCallback: _invoiceToFinish.operatorUsers,
          editForm: false,
          idLocation: _idLocation,
          closedInvoice: _invoiceToFinish.invoiceClosed,
          fromCompleteInvoice: true,
          callbackFinishInvoice : _finishInvoice,
        ),
      ),
    );
  }

  void _finishInvoice() async {
    if (_invoiceSelected.countOperators > 0) {
      bool endWashValue = false;
      Timestamp endWashData;
      int washingTimeValue;
      if (_invoiceSelected.startWashing && !_invoiceSelected?.endWash?? false) { //Finaliza la factura con final de lavado
        DateTime dateStart = _invoiceSelected.dateStartWashing.toDate();
        DateTime dateCurrent = DateTime.now();
        Duration diff = dateCurrent.difference(dateStart);
        int washCurrentDuration = diff.inMinutes;
        washingTimeValue = washCurrentDuration;
        endWashValue = true;
        endWashData = Timestamp.now();

        Invoice invoice = Invoice.copyWith(
          origin: _invoiceSelected,
          closedDate: Timestamp.now(),
          endWash: endWashValue,
          dateEndWash: endWashData,
          washingTime: washingTimeValue,
        );
        await _blocInvoice.saveInvoice(invoice);
      } else {  //Finaliza la factura sin final de lavado
        Invoice invoice = Invoice.copyWith(
          origin: _invoiceSelected,
          closedDate: Timestamp.now(),
        );
        await _blocInvoice.saveInvoice(invoice);
      }
      _validateSendCustomerNotification(_invoiceSelected);
      setState(() {});
      //_closeInvoiceMessage();
    }
  }

  void _callBackSelectPaymentMethod(PaymentMethod payment) {
    _selectedPaymentMethod = payment;
  }

  void _saveOperators(List<User> userList) async {
    int _countOperators = 0;
    List<User> _operatorsToSave = [];
    List<User> _selectedOperators = userList.where((u) => u.isSelected).toList();
    if (_selectedOperators.length > 0) {
      _selectedOperators.forEach((user) {
        var operatorSave = User.copyUserOperatorToSaveInvoice(
          id: user.id,
          name: user.name,
          operatorCommission: ((_invoiceSelected.totalCommission??0) / _selectedOperators.length).ceilToDouble(),
        );
        _operatorsToSave.add(operatorSave);
      });
      _countOperators = _selectedOperators.length;
      Invoice invoice = Invoice.copyWith(
        origin: _invoiceSelected,
        listOperators: _operatorsToSave,
        countOperators: _countOperators,
      );
      _invoiceSelected = invoice;
      await _blocInvoice.saveInvoice(invoice);
      setState(() {});
    }
  }

  void _closeInvoice(bool withPayment) async {
    MessagesUtils.showAlertWithLoading(context: context, title: 'Guardando..')
        .show();
    Invoice invoice;
    if (withPayment) {
      if (_selectedPaymentMethod.name.isNotEmpty) {
        invoice = Invoice.copyWith(
          origin: _invoiceSelected,
          paymentMethod: _selectedPaymentMethod.name,
          invoiceClosed: true,
        );
      } else return;
    } else {
      invoice = Invoice.copyWith(
        origin: _invoiceSelected,
        invoiceClosed: true,
      );
    }
    await _blocInvoice.saveInvoice(invoice);
    Navigator.pop(context);
  }

  void _validateSendCustomerNotification(Invoice invoiceToClose) {
    if (invoiceToClose.phoneNumber.isNotEmpty) {
      String message =
          "Spa CarWash Movil -- Estimado cliente. Le informamos que el servicio de lavado de su vehículo de placa ${invoiceToClose.placa}, ha finalizado y está listo para ser entregado ☑️. "
          "Cómo estamos comprometidos con tu satisfacción 😃, por favor ayúdanos con tu opinion en cortas respuestas en el siguinte link ➡️"
          "https://docs.google.com/forms/d/1gdq9rSR8pMqlukEalGLxF_m5954m7_Hpm5k5HYX89yU/edit";
      List<String> recipents = [invoiceToClose.phoneNumber];
      if (_location != null) {
        if (_location.sendMessageSms ?? false) {
          _sendSMS(message, recipents);
        } else if (_location.sendMessageWp ?? false) {
          _sendWhatsAppMessage(message, invoiceToClose.phoneNumber);
        }
      }
    }
  }

  void _sendSMS(String message, List<String> recipents) async {
    try {
      String _result =
          await FlutterSms.sendSMS(message: message, recipients: recipents)
              .catchError((onError) {
        print(onError);
      });
    } catch (_) {
      print(_);
    }
  }

  void _sendWhatsAppMessage(String message, String phoneNumber) async {
    try {
      if (phoneNumber.isNotEmpty) {
        //FlutterOpenWhatsapp.sendSingleMessage('57' + phoneNumber, message);
        //String url = 'https://api.whatsapp.com/send/?phone=57'+ phoneNumber + '&text=' + message + '&app_absent=1' ;
        String url = 'https://wa.me/57' + phoneNumber + '?text=' + message;
        launch(url);
      }
    } catch (_) {
      print(_);
    }
  }
}
