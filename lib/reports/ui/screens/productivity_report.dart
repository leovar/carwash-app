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
          )
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
      _listInvoices.forEach((item) {
        List<Invoice> invoicesPerUser = [];
        if (_cardList.length > 0) {
          CardReport cardInfo = _cardList.firstWhere(
            (x) =>
                x.operatorReference == item.userOperator &&
                x.locationName == item.locationName,
            orElse: () => null,
          );
          if (cardInfo == null) {
            invoicesPerUser.add(item);
            final newOperatorCard = CardReport(
                item.userOperatorName,
                item.userOperator,
                item.locationName,
                item.countProducts + item.countAdditionalProducts,
                item.totalPrice,
                invoicesPerUser);
            _cardList.add(newOperatorCard);
          } else {
            cardInfo.countServices = cardInfo.countServices +
                item.countProducts +
                item.countAdditionalProducts;
            cardInfo.totalPrice = cardInfo.totalPrice + item.totalPrice;
            List<Invoice> listGet = cardInfo.invoicesList;
            listGet.add(item);
            int indexData = _cardList.indexOf(cardInfo);
            _cardList[indexData] = cardInfo;
          }
        } else {
          invoicesPerUser.add(item);
          final newOperatorCard = CardReport(
            item.userOperatorName,
            item.userOperator,
            item.locationName,
            item.countProducts + item.countAdditionalProducts,
            item.totalPrice,
            invoicesPerUser,
          );
          _cardList.add(newOperatorCard);
        }
      });
      return _cardList;
    } catch (_error) {
      print(_error);
      return _cardList;
    }
  }

  Future<void> _openServicesDetail(DocumentReference operatorReference) async {
    List<ProductsCardDetail> _productList = [];
    List<Commission> commissionsList = await _blocCommission.getAllCommissions();
    final operatorInvoices = _listInvoices
        .where(
            (f) => f.userOperator == operatorReference && !f.cancelledInvoice)
        .toList();
    Alert(
        context: context,
        title: '',
        style: MessagesUtils.alertStyle,
        content: Center(
          child: CircularProgressIndicator(),
        ),
        buttons: []).show();

    List<Product> dataProducts = [];
    operatorInvoices.forEach((element) {
      dataProducts.addAll(element.invoiceProducts);
    });

    dataProducts.forEach((e) {
      var createdDate = e.dateAdded.toDate();
      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      final String dateFormatted = formatter.format(createdDate);
      if (_productList.length == 0) {
        ProductsCardDetail productDetail = _getProductCardToAdd(e, commissionsList);
        _productList.add(productDetail);
      } else {
        ProductsCardDetail _productInfo = _productList.firstWhere(
          (x) => x.dateServices == dateFormatted,
          orElse: () => null,
        );
        if (_productInfo == null) {
          ProductsCardDetail productDetail = _getProductCardToAdd(e, commissionsList);
          _productList.add(productDetail);
        } else {
          final commissionProd = commissionsList.firstWhere((c) => c.productType == e.productType && c.uidVehicleType == e.vehicleTypeUid, orElse: () => null);
          if (e.productType == 'Sencillo') {
            final countSimpleVehicle = _productInfo.countSimpleVehicle + (e.vehicleTypeUid == 1 ? 1 : 0);
            final countSimpleVan = _productInfo.countSimpleVan + (e.vehicleTypeUid == 2 ? 1 : 0);
            _productInfo.countSimpleServices = _productInfo.countSimpleServices + 1;
            _productInfo.totalSimpleValue = _productInfo.totalSimpleValue + e.price;
            _productInfo.countSimpleVehicle = countSimpleVehicle;
            _productInfo.countSimpleVan = countSimpleVan;
            _productInfo.totalSimpleVehicle = _productInfo.totalSimpleVehicle + (e.vehicleTypeUid == 1 ? e.price : 0);
            _productInfo.totalSimpleVan = _productInfo.totalSimpleVan + (e.vehicleTypeUid == 2 ? e.price : 0);
            _productInfo.totalPrice = _productInfo.totalPrice + e.price;
            if (commissionProd != null) {
              final commissionSimple = (e.vehicleTypeUid == 1 ? (countSimpleVehicle * commissionProd.value) : _productInfo.commissionSimpleVehicle);
              final commissionVan = (e.vehicleTypeUid == 2 ? (countSimpleVan * commissionProd.value) : _productInfo.commissionSimpleVan);
              _productInfo.commissionSimpleVehicle = commissionSimple;
              _productInfo.commissionSimpleVan = commissionVan;
              _productInfo.totalCommission = _productInfo.totalCommission + (e.vehicleTypeUid == 1 ? commissionSimple : commissionVan);
            }
          } else {
            _productInfo.countSpecialServices = _productInfo.countSpecialServices + 1;
            _productInfo.totalSpecialValue = _productInfo.totalSpecialValue + e.price;
            _productInfo.totalPrice = _productInfo.totalPrice + e.price;
            if (commissionProd != null) {
              final commissionSpecial = ((_productInfo.totalSpecialValue + e.price) * commissionProd.value) / 100;
              _productInfo.commissionSpecial = commissionSpecial;
              _productInfo.totalCommission = _productInfo.totalCommission + commissionSpecial;
            }
          }
        }
      }
    });

    /*
    dataProducts.forEach((e) {
      if (_productList.length == 0) {
        final productDetail = ProductsCardDetail(
            e.productType ?? 'Adicional', 1, e.price, e.dateAdded);
        _productList.add(productDetail);
      } else {
        ProductsCardDetail _productInfo = _productList.firstWhere(
          (x) => x.typeProductName == (e.productType ?? 'Adicional'),
          orElse: () => null,
        );
        if (_productInfo == null) {
          final productDetail = ProductsCardDetail(
              e.productType ?? 'Adicional', 1, e.price, e.dateAdded);
          _productList.add(productDetail);
        } else {
          _productInfo.countServices = _productInfo.countServices + 1;
          _productInfo.totalPrice = _productInfo.totalPrice + e.price;
          int indexData = _productList.indexOf(_productInfo);
          _productList[indexData] = _productInfo;
        }
      }
    });*/

    if (dataProducts.length > 0) {
      Navigator.pop(context);
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return BlocProvider(
            bloc: BlocReports(),
            child: ProductivityUserDetailPage(
              productsList: _productList,
            ));
      }));
      /*
      Alert(
          context: context,
          title: 'Detalle de productos',
          style: MessagesUtils.alertStyle,
          content: InfoDetailCardProductivity(
            productivityProducts: _productList,
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
          ]).show();*/
    }
  }

  ProductsCardDetail _getProductCardToAdd(Product product, List<Commission> commissionsList) {
    var createdDate = product.dateAdded.toDate();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String dateFormatted = formatter.format(createdDate);
    ProductsCardDetail productDetail;
    Commission commissionProd = commissionsList.firstWhere((c) => c.productType == product.productType && c.uidVehicleType == product.vehicleTypeUid, orElse: () => null);
    double commissionVehicle = 0;
    if (commissionProd != null) {
      commissionVehicle = commissionProd.value;
    }
    if (product.productType == 'Sencillo') {
      productDetail = ProductsCardDetail(
          1,
          0,
          product.price,
          0,
          product.vehicleTypeUid == 1 ? 1 : 0,
          product.vehicleTypeUid == 2 ? 1 : 0,
          product.vehicleTypeUid == 1 ? product.price : 0,
          product.vehicleTypeUid == 2 ? product.price : 0,
          product.vehicleTypeUid == 1 ? commissionVehicle : 0,
          product.vehicleTypeUid == 2 ? commissionVehicle : 0,
          0,
          commissionVehicle,
          product.price,
          dateFormatted);
    } else {
      productDetail = ProductsCardDetail(
          0, 1, 0, product.price, 0, 0, 0, 0, 0, 0, commissionVehicle, commissionVehicle, product.price, dateFormatted);
    }
    return productDetail;
  }

  void _updateInvoices(List<Invoice> _invoice) async {
    ///TODO este metodo se llama para agregar los campos de countProducts a las facturas que no lo tienen aun
    //_blocReports.updateInfoInvoices(_invoice);
    //_blocReports.updateInfoProductsInvoice(_invoice);
    //_blocReports.addIdToProductInvoice(_invoice);
  }
}
