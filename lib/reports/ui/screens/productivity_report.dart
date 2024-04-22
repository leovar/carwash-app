import 'dart:ffi';

import 'package:car_wash_app/commission/bloc/bloc_commission.dart';
import 'package:car_wash_app/commission/model/commission.dart';
import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/reports/bloc/bloc_reports.dart';
import 'package:car_wash_app/reports/model/card_report.dart';
import 'package:car_wash_app/reports/model/products_card_detail.dart';
import 'package:car_wash_app/reports/ui/screens/productivity_user_detail_page.dart';
import 'package:car_wash_app/reports/ui/widgets/info_detail_card_productivity.dart';
import 'package:car_wash_app/reports/ui/widgets/item_productivity_report_list.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProductivityReport extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProductivityReport();
}

class _ProductivityReport extends State<ProductivityReport> {
  BlocReports _blocReports = BlocReports();
  BlocLocation _blocLocation = BlocLocation();
  BlocInvoice _blocInvoice = BlocInvoice();
  BlocCommission _blocCommission = BlocCommission();
  List<DropdownMenuItem<Location>> _dropdownMenuItems;
  Location _selectedLocation;
  List<CardReport> _listCardReport = [];
  List<Invoice> _listInvoices = [];

  final _textDateInit = TextEditingController();
  final _textDateFinal = TextEditingController();
  var _dateTimeInit = DateTime(DateTime.now().year, DateTime.now().month, 1);
  var _dateTimeFinal = DateTime.now();
  DocumentReference _locationReference;
  var formatter = new DateFormat('dd-MM-yyyy');

  @override
  void initState() {
    super.initState();
    _textDateInit.text = formatter.format(_dateTimeInit);
    _textDateFinal.text = formatter.format(_dateTimeFinal);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        _filterParamsReport(),
        SizedBox(
          height: 8.0,
        ),
        Expanded(
          child: _getDataReport(),
        ),
      ],
    );
  }

  Widget _filterParamsReport() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(
            child: _locationsList(),
          ),
          Flexible(
            child: TextField(
              controller: _textDateInit,
              decoration: InputDecoration(
                labelText: 'Fecha Desde',
              ),
              keyboardType: TextInputType.datetime,
              readOnly: true,
              onTap: () {
                _datePickerFrom();
              },
            ),
          ),
          Flexible(
            child: TextField(
              controller: _textDateFinal,
              decoration: InputDecoration(
                labelText: 'Fecha Hasta',
              ),
              keyboardType: TextInputType.datetime,
              readOnly: true,
              onTap: () {
                _datePickerFinal();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _getDataReport() {
    if (_locationReference == null) {
      return _emptyLocation();
    } else {
      return StreamBuilder(
        stream: _blocReports.productivityReportListStream(
          _locationReference,
          _dateTimeInit,
          _dateTimeFinal,
        ),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return _containerList(snapshot);
        },
      );
    }
  }

  Widget _emptyLocation() {
    return Container(
      child: Center(
        child: Text('No hay información para mostrar'),
      ),
    );
  }

  Widget _containerList(AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return Center(
          child: CircularProgressIndicator(),
        );
      default:
        _listInvoices =
            _blocReports.buildProductivityReportList(snapshot.data.documents);
        //_updateInvoices(_listInvoices); //TODO esta llamada se debe comentar o eliminar cuando se actualizce al app en los celulares que la usan
        _listCardReport = _processInvoicesOperator(
            _listInvoices.where((f) => !f.cancelledInvoice).toList());
        _listCardReport
            .sort((a, b) => b.countServices.compareTo(a.countServices));
    }

    if (_listInvoices.length > 0 && _selectedLocation != null) {
      return ListView.builder(
        itemCount: _listCardReport.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return ItemProductivityReportList(
              cardReport: _listCardReport[index],
              servicesDetail: _openServicesDetail);
        },
      );
    } else {
      return _emptyLocation();
    }
  }

  /// Locations filter section
  Widget _locationsList() {
    return StreamBuilder(
      stream: _blocLocation.locationsStream,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(),
            );
          default:
            return _chargeDropLocations(snapshot);
        }
      },
    );
  }

  Widget _chargeDropLocations(AsyncSnapshot snapshot) {
    List<Location> locationList =
        _blocLocation.buildLocations(snapshot.data.documents);
    _dropdownMenuItems = builtDropdownMenuItems(locationList);

    return DropdownButton(
      isExpanded: true,
      items: _dropdownMenuItems,
      value: _selectedLocation,
      onChanged: onChangeDropDawn,
      hint: Text(
        "Seleccione la Sede...",
      ),
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: Theme.of(context).cardColor,
      ),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(
        fontFamily: "AvenirNext",
        fontWeight: FontWeight.normal,
        color: Theme.of(context).cardColor,
      ),
      underline: Container(
        height: 1,
        color: Theme.of(context).cursorColor,
      ),
    );
  }

  List<DropdownMenuItem<Location>> builtDropdownMenuItems(List locations) {
    List<DropdownMenuItem<Location>> listItems = List();
    for (Location documentLoc in locations) {
      listItems.add(
        DropdownMenuItem(
          value: documentLoc,
          child: Text(
            documentLoc.locationName,
          ),
        ),
      );
    }
    return listItems;
  }

  /// Functions
  onChangeDropDawn(Location selectedLocation) async {
    _locationReference =
        await _blocLocation.getLocationReference(selectedLocation.id);
    setState(() {
      _selectedLocation = selectedLocation;
    });
  }

  Future<Null> _datePickerFrom() async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _dateTimeInit,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _dateTimeInit) {
      setState(() {
        _dateTimeInit = picked;
        _textDateInit.text = formatter.format(_dateTimeInit);
      });
    }
  }

  Future<Null> _datePickerFinal() async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: _dateTimeFinal,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _dateTimeFinal) {
      setState(() {
        _dateTimeFinal = picked;
        _textDateFinal.text = formatter.format(_dateTimeFinal);
      });
    }
  }

  List<CardReport> _processInvoicesOperator(List<Invoice> _listInvoices) {
    List<CardReport> _cardList = [];
    try {
      _listInvoices.forEach((itemInvoice) {
        if (itemInvoice.operatorUsers != null) {
          itemInvoice.operatorUsers.forEach((item) {
            List<Invoice> invoicesPerUser = [];
            double _totalPrice = itemInvoice.totalPrice / itemInvoice.countOperators;
            CardReport cardInfo = _cardList.length > 0 ? _cardList.firstWhere(
                  (x) => x.operatorName == item.name && x.locationName == itemInvoice.locationName, orElse: () => null,) : null;
            if (cardInfo == null) {
              invoicesPerUser.add(itemInvoice);
              final newOperatorCard = CardReport(
                  item.name,
                  item.id,
                  itemInvoice.locationName,
                  itemInvoice.countOperators == 1 ? itemInvoice.countProducts + itemInvoice.countAdditionalProducts : 0,
                  itemInvoice.countOperators > 1 ? itemInvoice.countProducts + itemInvoice.countAdditionalProducts : 0,
                  _totalPrice,
                  invoicesPerUser);
              _cardList.add(newOperatorCard);
            } else {
              cardInfo.countServices = cardInfo.countServices + (itemInvoice.countOperators == 1 ? (itemInvoice.countProducts + itemInvoice.countAdditionalProducts) : 0);
              cardInfo.countSharedServices = cardInfo.countSharedServices + (itemInvoice.countOperators > 1 ? (itemInvoice.countProducts + itemInvoice.countAdditionalProducts) : 0);
              cardInfo.totalPrice = cardInfo.totalPrice + _totalPrice;
              List<Invoice> listGet = cardInfo.invoicesList;
              listGet.add(itemInvoice);
              int indexData = _cardList.indexOf(cardInfo);
              _cardList[indexData] = cardInfo;
            }
          });
        }
      });
      return _cardList;
    } catch (_error) {
      print(_error);
      Fluttertoast.showToast(msg: "Error generando el informe: $_error", toastLength: Toast.LENGTH_LONG);
      return _cardList;
    }
  }

  Future<void> _openServicesDetail(String operatorName, List<Invoice> _invoiceOperatorList) async {
    List<ProductsCardDetail> _productList = [];
    List<Commission> commissionsList = await _blocCommission.getAllCommissions();
    Alert(
        context: context,
        title: '',
        style: MessagesUtils.alertStyle,
        content: Center(
          child: CircularProgressIndicator(),
        ),
        buttons: []).show();

    List<Product> dataProducts = [];
    _invoiceOperatorList.forEach((element) {
      dataProducts.addAll(element.invoiceProducts);
    });

    dataProducts.forEach((e) {
      var createdDate = e.dateAdded.toDate();
      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      final String dateFormatted = formatter.format(createdDate);
      if (_productList.length == 0) {
        ProductsCardDetail _productDetail = _startCardDetail(e); //_getProductCardToAdd(e, commissionsList);
        _productDetail = _commissionProcess(commissionsList, e, _productDetail);
        _productList.add(_productDetail);
      } else {
        ProductsCardDetail _productInfo = _productList.firstWhere(
          (x) => x.dateServices == dateFormatted,
          orElse: () => null,
        );
        if (_productInfo == null) {
          ProductsCardDetail _productDetail = _startCardDetail(e); //_getProductCardToAdd(e, commissionsList);
          _productDetail = _commissionProcess(commissionsList, e, _productDetail);
          _productList.add(_productDetail);
        } else {
          _productInfo = _commissionProcess(commissionsList, e, _productInfo);
        }
      }
    });

    if (dataProducts.length > 0) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return BlocProvider(
            bloc: BlocReports(),
            child: ProductivityUserDetailPage(
              productsList: _productList,
            ));
      }));
    }
  }

  ProductsCardDetail _commissionProcess(List<Commission> commissionsList, Product prod, ProductsCardDetail _currentProd) {
    final commissionProd = commissionsList.firstWhere((c) => c.productType == prod.productType && c.uidVehicleType == prod.vehicleTypeUid, orElse: () => null);
    int countService = 0;
    double totalService = 0;
    double calculateComm = 0;
    double totalCalculateComm = 0;
    bool isNormal = false;
    _currentProd.totalPrice = _currentProd.totalPrice + prod.price;
    switch(prod.vehicleTypeUid) {
      case 1: {
        if (prod.productType == 'Sencillo') {
          countService = _currentProd.countSimpleAuto + 1;
          totalService = _currentProd.totalSimpleAuto + prod.price;
          _currentProd.countSimpleAuto = countService;
          _currentProd.totalSimpleAuto = totalService;
        } else {
          countService = _currentProd.countSpecialAuto + 1;
          totalService = _currentProd.totalSpecialAuto + prod.price;
          _currentProd.countSpecialAuto = countService;
          _currentProd.totalSpecialAuto = totalService;
        }
      }
      break;
      case 2: {
        if (prod.productType == 'Sencillo') {
          countService = _currentProd.countSimpleVan + 1;
          totalService = _currentProd.totalSimpleVan + prod.price;
          _currentProd.countSimpleVan = countService;
          _currentProd.totalSimpleVan = totalService;
        } else {
          countService = _currentProd.countSpecialVan + 1;
          totalService = _currentProd.totalSpecialVal + prod.price;
          _currentProd.countSpecialVan = countService;
          _currentProd.totalSpecialVal = totalService;
        }
      }
      break;
      case 3: {
        if (prod.productType == 'Sencillo') {
          countService = _currentProd.countSimpleMoto + 1;
          totalService = _currentProd.totalSimpleMoto + prod.price;
          _currentProd.countSimpleMoto = countService;
          _currentProd.totalSimpleMoto = totalService;
        } else {
          countService = _currentProd.countSpecialMoto + 1;
          totalService = _currentProd.totalSpecialMoto + prod.price;
          _currentProd.countSpecialMoto = countService;
          _currentProd.totalSpecialMoto = totalService;
        }
      }
      break;
      case 4: {
        if (prod.productType == 'Sencillo') {
          countService = _currentProd.countSimpleBicycle + 1;
          totalService = _currentProd.totalSimpleBicycle + prod.price;
          _currentProd.countSimpleBicycle = countService;
          _currentProd.totalSimpleBicycle = totalService;
        } else {
          countService = _currentProd.countSpecialBicycle + 1;
          totalService = _currentProd.totalSpecialBicycle + prod.price;
          _currentProd.countSpecialBicycle = countService;
          _currentProd.totalSpecialBicycle = totalService;
        }
      }
      break;
    }

    if (commissionProd != null) {
      if (commissionProd.commissionThreshold > 0) {
        if (prod.price <= commissionProd.commissionThreshold) {
          if (commissionProd.calculatePerCount) {
            calculateComm = commissionProd.isValue ? countService * commissionProd.valueBeforeThreshold : (countService * commissionProd.valueBeforeThreshold) / 100;
          } else {
            calculateComm = commissionProd.isValue ? prod.price * commissionProd.valueBeforeThreshold : (prod.price * commissionProd.valueBeforeThreshold) / 100;
          }
        } else {
          isNormal = true;
        }
      } else {
        isNormal = true;
      }
      if (isNormal) {
        if (commissionProd.calculatePerCount) {
          calculateComm = commissionProd.isValue ? countService * commissionProd.value : (countService * commissionProd.value) / 100;
        } else {
          calculateComm = commissionProd.isValue ? prod.price * commissionProd.value : (prod.price * commissionProd.value) / 100;
        }
      }
    }

    switch(prod.vehicleTypeUid) {
      case 1: {
        if (prod.productType == 'Sencillo') {
          totalCalculateComm = commissionProd.calculatePerCount ? calculateComm : _currentProd.commissionSimpleAuto + calculateComm;
          _currentProd.commissionSimpleAuto = totalCalculateComm;
        } else {
          totalCalculateComm = commissionProd.calculatePerCount ? calculateComm : _currentProd.commissionSpecialAuto + calculateComm;
          _currentProd.commissionSpecialAuto = totalCalculateComm;
        }
      }
      break;
      case 2: {
        if (prod.productType == 'Sencillo') {
          totalCalculateComm = commissionProd.calculatePerCount ? calculateComm : _currentProd.commissionSimpleVan + calculateComm;
          _currentProd.commissionSimpleVan = totalCalculateComm;
        } else {
          totalCalculateComm = commissionProd.calculatePerCount ? calculateComm : _currentProd.commissionSpecialVan + calculateComm;
          _currentProd.commissionSpecialVan = totalCalculateComm;
        }
      }
      break;
      case 3: {
        if (prod.productType == 'Sencillo') {
          totalCalculateComm = commissionProd.calculatePerCount ? calculateComm : _currentProd.commissionSimpleMoto + calculateComm;
          _currentProd.commissionSimpleMoto = totalCalculateComm;
        } else {
          totalCalculateComm = commissionProd.calculatePerCount ? calculateComm : _currentProd.commissionSpecialMoto + calculateComm;
          _currentProd.commissionSpecialMoto = totalCalculateComm;
        }
      }
      break;
      case 4: {
        if (prod.productType == 'Sencillo') {
          totalCalculateComm = commissionProd.calculatePerCount ? calculateComm : _currentProd.commissionSimpleBicycle + calculateComm;
          _currentProd.commissionSimpleBicycle = totalCalculateComm;
        } else {
          totalCalculateComm = commissionProd.calculatePerCount ? calculateComm : _currentProd.commissionSpecialBicycle + calculateComm;
          _currentProd.commissionSpecialBicycle = totalCalculateComm;
        }
      }
      break;
    }
    _currentProd.totalCommission = _currentProd.commissionSimpleAuto
        + _currentProd.commissionSpecialAuto
        + _currentProd.commissionSimpleVan
        + _currentProd.commissionSpecialVan
        + _currentProd.commissionSimpleMoto
        + _currentProd.commissionSpecialMoto
        + _currentProd.commissionSimpleBicycle
        + _currentProd.commissionSpecialBicycle;


    if (prod.productType == 'Sencillo') {
      _currentProd.countSimpleServices = _currentProd.countSimpleServices + 1;
      _currentProd.totalSimpleValue = _currentProd.totalSimpleValue + prod.price;
    } else {
      _currentProd.countSpecialServices = _currentProd.countSpecialServices + 1;
      _currentProd.totalSpecialValue = _currentProd.totalSpecialValue + prod.price;
    }

    return _currentProd;
  }

  ProductsCardDetail _startCardDetail(Product prod) {
    var createdDate = prod.dateAdded.toDate();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String dateFormatted = formatter.format(createdDate);
    ProductsCardDetail productDetail =ProductsCardDetail(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,dateFormatted);
    return productDetail;
  }

  void _updateInvoices(List<Invoice> _invoice) async {
    ///TODO este metodo se llama para agregar los campos de countProducts a las facturas que no lo tienen aun
    _blocReports.updateInfoOperatorsInvoices(_invoice);
    //_blocReports.updateInfoProductsInvoice(_invoice);
    //_blocReports.addIdToProductInvoice(_invoice);
  }
}
