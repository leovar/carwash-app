import 'dart:io';
import 'package:car_wash_app/commission/bloc/bloc_commission.dart';
import 'package:car_wash_app/commission/model/commission.dart';
import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/reports/bloc/bloc_reports.dart';
import 'package:car_wash_app/reports/model/card_report.dart';
import 'package:car_wash_app/reports/model/invoices_date_count.dart';
import 'package:car_wash_app/reports/model/products_card_detail.dart';
import 'package:car_wash_app/reports/ui/screens/productivity_user_detail_page.dart';
import 'package:car_wash_app/reports/ui/widgets/item_productivity_report_list.dart';
import 'package:car_wash_app/user/model/sysUser.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as path_prov;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:intl/intl.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class ProductivityReport extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProductivityReport();
}

class _ProductivityReport extends State<ProductivityReport> {
  BlocReports _blocReports = BlocReports();
  BlocLocation _blocLocation = BlocLocation();
  BlocInvoice _blocInvoice = BlocInvoice();
  BlocCommission _blocCommission = BlocCommission();
  late List<DropdownMenuItem<Location>> _dropdownMenuItems;
  Location _selectedLocation = new Location();
  List<CardReport> _listCardReport = [];
  List<Invoice> _listInvoices = [];

  final _textDateInit = TextEditingController();
  final _textDateFinal = TextEditingController();
  var _dateTimeInit = DateTime(DateTime.now().year, DateTime.now().month, 1);
  var _dateTimeFinal = DateTime.now();
  DocumentReference _locationReference = FirebaseFirestore.instance.collection('locations').doc('defaultDocId');
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
        SizedBox(height: 4.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Descargar',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            IconButton(
              icon: Icon(
                Icons.file_download,
                color: Theme.of(context).colorScheme.secondary,
              ),
              iconSize: 32,
              onPressed: _downloadReport,
            ),
          ],
        ),
        SizedBox(height: 4.0),
        Expanded(child: _getDataReport()),
      ],
    );
  }

  Widget _filterParamsReport() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Flexible(child: _locationsList()),
          Flexible(
            child: TextField(
              controller: _textDateInit,
              decoration: InputDecoration(labelText: 'Fecha Desde'),
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
              decoration: InputDecoration(labelText: 'Fecha Hasta'),
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
    if (_locationReference.id == 'defaultDocId' || _selectedLocation.id == null) {
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
      child: Center(child: Text('No hay información para mostrar')),
    );
  }

  Widget _containerList(AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        return Center(child: CircularProgressIndicator());
      default:
        _listInvoices = _blocReports.buildProductivityReportList(
          snapshot.data.docs,
        );
        //_updateInvoices(_listInvoices); //TODO esta llamada se debe comentar o eliminar cuando se actualizce al app en los celulares que la usan
        _listCardReport = _processInvoicesOperator(
          _listInvoices
              .where((f) => !(f.cancelledInvoice??false) && (f.invoiceClosed??false))
              .toList(),
        );
        _listCardReport.sort(
          (a, b) => b.countServices.compareTo(a.countServices),
        );
    }

    if (_listInvoices.length > 0) {
      return ListView.builder(
        itemCount: _listCardReport.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return ItemProductivityReportList(
            cardReport: _listCardReport[index],
            servicesDetail: _openServicesDetail,
          );
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
            return Center(child: CircularProgressIndicator());
          default:
            return _chargeDropLocations(snapshot);
        }
      },
    );
  }

  Widget _chargeDropLocations(AsyncSnapshot snapshot) {
    List<Location> locationList = _blocLocation.buildLocations(
      snapshot.data.docs,
    );
    _dropdownMenuItems = builtDropdownMenuItems(locationList);

    return DropdownButton(
      isExpanded: true,
      items: _dropdownMenuItems,
      value: _selectedLocation,
      onChanged: onChangeDropDawn,
      hint: Text("Seleccione la Sede..."),
      icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).cardColor),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(
        fontFamily: "AvenirNext",
        fontWeight: FontWeight.normal,
        color: Theme.of(context).cardColor,
      ),
      underline: Container(height: 1, color: Theme.of(context).textSelectionTheme.cursorColor),
    );
  }

  List<DropdownMenuItem<Location>> builtDropdownMenuItems(List locations) {
    List<DropdownMenuItem<Location>> listItems = [];
    if (_selectedLocation.id == null) {
      listItems.add(
        DropdownMenuItem(
          value: _selectedLocation,
          child: Text('Seleccione una sede ...'),
        ),
      );
    } else {
      var locationList = new Location();
      listItems.add(
        DropdownMenuItem(
          value: locationList,
          child: Text('Seleccione una sede ...'),
        ),
      );
    }
    for (Location documentLoc in locations) {
      listItems.add(
        DropdownMenuItem(
          value: documentLoc,
          child: Text(documentLoc.locationName??''),
        ),
      );
    }

    return listItems;
  }

  /// Functions
  onChangeDropDawn(Location? selectedLocation) async {
    if ((selectedLocation?.id??'') == '') {
      setState(() {
        if (selectedLocation != null) {
          _selectedLocation = selectedLocation;
        }
      });
    } else {
      _locationReference = await _blocLocation.getLocationReference(
        selectedLocation?.id??'',
      );
      setState(() {
        if (selectedLocation != null) {
          _selectedLocation = selectedLocation;
        }
      });
    }
  }

  Future<Null> _datePickerFrom() async {
    final DateTime? picked = await showDatePicker(
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
    final DateTime? picked = await showDatePicker(
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
          itemInvoice.operatorUsers?.forEach((item) {
            List<Invoice> invoicesPerUser = [];
            double _totalPrice = (itemInvoice.totalPrice??0) / (itemInvoice.countOperators??0);
            CardReport? cardInfo =
            _cardList.length > 0
                ? _cardList.firstWhere((x) => x.operatorName == item.name && x.locationName == itemInvoice.locationName,
              orElse: () => new CardReport('', '', '', 0, 0, 0, []),
            )
                : null;
            if (cardInfo == null || cardInfo.operatorName == '') {
              invoicesPerUser.add(itemInvoice);
              final newOperatorCard = CardReport(
                  item.name,
                  item.id ?? '',
                  itemInvoice.locationName ?? '',
                  itemInvoice.countOperators == 1
                      ? ((itemInvoice.countProducts??0) +
                      (itemInvoice.countAdditionalProducts??0))
                      : 0,
                  (itemInvoice.countOperators??0) > 1
                      ? ((itemInvoice.countProducts??0) +
                      (itemInvoice.countAdditionalProducts??0))
                      : 0,
                  _totalPrice,
                  invoicesPerUser);
              _cardList.add(newOperatorCard);
            } else {
              cardInfo.countServices = cardInfo.countServices +
                  (itemInvoice.countOperators == 1
                      ? ((itemInvoice.countProducts??0) +
                      (itemInvoice.countAdditionalProducts??0))
                      : 0);
              cardInfo.countSharedServices = cardInfo.countSharedServices +
                  ((itemInvoice.countOperators??0) > 1
                      ? ((itemInvoice.countProducts??0) +
                      (itemInvoice.countAdditionalProducts??0))
                      : 0);
              cardInfo.totalPrice = cardInfo.totalPrice + _totalPrice;
              List<Invoice> listGet = cardInfo.invoicesList;
              listGet.add(itemInvoice);
              int indexData = _cardList.indexOf(cardInfo);
              if (indexData != -1) {
                _cardList[indexData] = cardInfo;
              } else {
                print(_cardList);
                print(cardInfo);
              }
            }
          });
        }
      });
      return _cardList;
    } catch (_error) {
      print(_error);
      Fluttertoast.showToast(
        msg: "Error generando el informe: $_error",
        toastLength: Toast.LENGTH_LONG,
      );
      return _cardList;
    }
  }

  Future<void> _openServicesDetail(
    String operatorName,
    List<Invoice> _invoiceOperatorList,
  ) async {
    List<ProductsCardDetail> _productList = [];
    List<InvoicesDateCount> _invoicesPerDate = [];
    List<Commission> commissionsList = await _blocCommission.getAllCommissions();
    Alert(
      context: context,
      title: '',
      style: MessagesUtils.alertStyle,
      content: Center(child: CircularProgressIndicator()),
      buttons: [],
    ).show();

    List<Product> dataProducts = [];
    _invoiceOperatorList.forEach((element) {
      if (element.invoiceProducts != null) {
        dataProducts.addAll(element.invoiceProducts??[]);
      }
      var createdDate = element.creationDate!.toDate();
      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      final String dateFormatted = formatter.format(createdDate);
      if (_invoicesPerDate.length == 0) {
        _invoicesPerDate.add(new InvoicesDateCount(dateFormatted, 1));
      } else {
        InvoicesDateCount _countInvoice = _invoicesPerDate.firstWhere((item) => item.invoiceDate == dateFormatted, orElse: () => new InvoicesDateCount('', 0));
        if (_countInvoice.invoiceDate == '') {
          _invoicesPerDate.add(new InvoicesDateCount(dateFormatted, 1));
        } else {
          _countInvoice.countInvoices = _countInvoice.countInvoices + 1;
        }
      }
    });

    dataProducts.forEach((e) {
      var createdDate = e.dateAdded!.toDate();
      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      final String dateFormatted = formatter.format(createdDate);
      InvoicesDateCount invoicesPerDateProd = _invoicesPerDate.firstWhere((item) => item.invoiceDate == dateFormatted);
      if (_productList.length == 0) {
        ProductsCardDetail _productDetail = _startCardDetail(e, invoicesPerDateProd.countInvoices); //_getProductCardToAdd(e, commissionsList);
        _productDetail = _commissionProcess(commissionsList, e, _productDetail);
        _productList.add(_productDetail);
      } else {
        ProductsCardDetail _productInfo = _productList.firstWhere(
          (x) => x.dateServices == dateFormatted,
          orElse: () => new ProductsCardDetail(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', invoicesPerDateProd.countInvoices),
        );
        if (_productInfo.dateServices == '') {
          ProductsCardDetail _productDetail = _startCardDetail(e, invoicesPerDateProd.countInvoices); //_getProductCardToAdd(e, commissionsList);
          _productDetail = _commissionProcess(commissionsList, e, _productDetail);
          _productList.add(_productDetail);
        } else {
          _productInfo = _commissionProcess(commissionsList, e, _productInfo);
        }
      }
    });

    if (dataProducts.length > 0) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return BlocProvider(
              bloc: BlocReports(),
              child: ProductivityUserDetailPage(productsList: _productList, operatorNameList: operatorName),
            );
          },
        ),
      );
    }
  }

  ProductsCardDetail _commissionProcess(
    List<Commission> commissionsList,
    Product prod,
    ProductsCardDetail _currentProd,
  ) {
    double countService = 0;
    _currentProd.totalPrice = _currentProd.totalPrice + ((prod.price??0) / (prod.countOperatorsInvoice??0));
    if (prod.countOperatorsInvoice == 1) {
      switch (prod.vehicleTypeUid) {
        case 1:
          {
            // Auto
            if (prod.productType == 'Sencillo') {
              countService = (_currentProd.countSimpleAuto + 1).toDouble();
              _currentProd.countSimpleAuto = countService.toInt();
              _currentProd.totalSimpleAuto = (_currentProd.totalSimpleAuto + (prod.price??0));
              _currentProd.commissionSimpleAuto = (_currentProd.commissionSimpleAuto + (prod.productCommission ?? 0));
            } else {
              countService = (_currentProd.countSpecialAuto + 1).toDouble();
              _currentProd.countSpecialAuto = countService.toInt();
              _currentProd.totalSpecialAuto = (_currentProd.totalSpecialAuto + (prod.price??0));
              _currentProd.commissionSpecialAuto = (_currentProd.commissionSpecialAuto + (prod.productCommission ?? 0));
            }
          }
          break;
        case 2:
          {
            //Camioneta
            if (prod.productType == 'Sencillo') {
              countService = (_currentProd.countSimpleVan + 1).toDouble();
              _currentProd.countSimpleVan = countService.toInt();
              _currentProd.totalSimpleVan =
              (_currentProd.totalSimpleVan + (prod.price??0));
              _currentProd.commissionSimpleVan =
              (_currentProd.commissionSimpleVan +
                  (prod.productCommission ?? 0));
            } else {
              countService = (_currentProd.countSpecialVan + 1).toDouble();
              _currentProd.countSpecialVan = countService.toInt();
              _currentProd.totalSpecialVal =
              (_currentProd.totalSpecialVal + (prod.price??0));
              _currentProd.commissionSpecialVan =
              (_currentProd.commissionSpecialVan +
                  (prod.productCommission ?? 0));
            }
          }
          break;
        case 3:
          {
            //Moto
            if (prod.productType == 'Sencillo') {
              countService = (_currentProd.countSimpleMoto + 1).toDouble();
              _currentProd.countSimpleMoto = countService.toInt();
              _currentProd.totalSimpleMoto =
              (_currentProd.totalSimpleMoto + (prod.price??0));
              _currentProd.commissionSimpleMoto = (_currentProd.commissionSimpleMoto + (prod.productCommission ?? 0));
            } else {
              countService = (_currentProd.countSpecialMoto + 1).toDouble();
              _currentProd.countSpecialMoto = countService.toInt();
              _currentProd.totalSpecialMoto = (_currentProd.totalSpecialMoto + (prod.price??0));
              _currentProd.commissionSpecialMoto = (_currentProd.commissionSpecialMoto + (prod.productCommission ?? 0));
            }
          }
          break;
        case 4:
          {
            //Bicicleta
            if (prod.productType == 'Sencillo') {
              countService = (_currentProd.countSimpleBicycle + 1).toDouble();
              _currentProd.countSimpleBicycle = countService.toInt();
              _currentProd.totalSimpleBicycle =
              (_currentProd.totalSimpleBicycle + (prod.price??0));
              _currentProd.commissionSimpleBicycle =
              (_currentProd.commissionSimpleBicycle +
                  (prod.productCommission ?? 0));
            } else {
              countService = (_currentProd.countSpecialBicycle + 1).toDouble();
              _currentProd.countSpecialBicycle = countService.toInt();
              _currentProd.totalSpecialBicycle =
              (_currentProd.totalSpecialBicycle + (prod.price??0));
              _currentProd.commissionSpecialBicycle =
              (_currentProd.commissionSpecialBicycle +
                  (prod.productCommission ?? 0));
            }
          }
          break;
      }
    } else {
      countService = (1 / (prod.countOperatorsInvoice??0));
      _currentProd.countSharedServices = _currentProd.countSharedServices + 1;
      _currentProd.totalSharedValue =
      (_currentProd.totalSharedValue +
          ((prod.price??0) / (prod.countOperatorsInvoice??0)));
      _currentProd.commissionSharedServices =
      (_currentProd.commissionSharedServices +
          ((prod.productCommission??0) / (prod.countOperatorsInvoice??0)));
    }

    _currentProd.totalCommission =
        _currentProd.commissionSimpleAuto +
        _currentProd.commissionSpecialAuto +
        _currentProd.commissionSimpleVan +
        _currentProd.commissionSpecialVan +
        _currentProd.commissionSimpleMoto +
        _currentProd.commissionSpecialMoto +
        _currentProd.commissionSimpleBicycle +
        _currentProd.commissionSpecialBicycle +
        _currentProd.commissionSharedServices;

    if (prod.countOperatorsInvoice == 1) {
      if (prod.productType == 'Sencillo') {
        _currentProd.countSimpleServices = _currentProd.countSimpleServices + 1;
        _currentProd.totalSimpleValue =
            _currentProd.totalSimpleValue + (prod.price??0);
      } else {
        _currentProd.countSpecialServices =
            _currentProd.countSpecialServices + 1;
        _currentProd.totalSpecialValue =
            _currentProd.totalSpecialValue + (prod.price??0);
      }
    }
    return _currentProd;
  }

  ///TODO Este método fue usado para calcular la comisión solo para visualización en el informe de pantalla (se puede eliminar despues de hacer test en sede)
  /// fue reemplazado calculando la comisión al guardar la factura y agregar los operadores
  ProductsCardDetail _commissionProcessOld(
    List<Commission> commissionsList,
    Product prod,
    ProductsCardDetail _currentProd,
  ) {
    final commissionProd = commissionsList.firstWhere(
      (c) =>
          c.productType == prod.productType &&
          c.uidVehicleType == prod.vehicleTypeUid,
      orElse: () => new Commission(),
    );
    double countService = 0;
    double _calculateComm = 0;
    double totalCalculateComm = 0;
    _currentProd.totalPrice =
        _currentProd.totalPrice + ((prod.price??0) / (prod.countOperatorsInvoice??0));
    if (prod.countOperatorsInvoice == 1) {
      switch (prod.vehicleTypeUid) {
        case 1:
          {
            // Auto
            if (prod.productType == 'Sencillo') {
              countService = (_currentProd.countSimpleAuto + 1).toDouble();
              _currentProd.countSimpleAuto = countService.toInt();
              _currentProd.totalSimpleAuto =
                  _currentProd.totalSimpleAuto + (prod.price??0);
              _calculateComm = _calculateCommissionValue(
                commissionProd,
                prod,
                countService,
              );
              totalCalculateComm =
                  commissionProd.calculatePerCount??false
                      ? _calculateComm
                      : _currentProd.commissionSimpleAuto + _calculateComm;
              _currentProd.commissionSimpleAuto = totalCalculateComm;
            } else {
              countService = (_currentProd.countSpecialAuto + 1).toDouble();
              _currentProd.countSpecialAuto = countService.toInt();
              _currentProd.totalSpecialAuto =
                  _currentProd.totalSpecialAuto + (prod.price??0);
              _calculateComm = _calculateCommissionValue(
                commissionProd,
                prod,
                countService,
              );
              totalCalculateComm =
                  commissionProd.calculatePerCount??false
                      ? _calculateComm
                      : _currentProd.commissionSpecialAuto + _calculateComm;
              _currentProd.commissionSpecialAuto = totalCalculateComm;
            }
          }
          break;
        case 2:
          {
            //Camioneta
            if (prod.productType == 'Sencillo') {
              countService = (_currentProd.countSimpleVan + 1).toDouble();
              _currentProd.countSimpleVan = countService.toInt();
              _currentProd.totalSimpleVan =
                  _currentProd.totalSimpleVan + (prod.price??0);
              _calculateComm = _calculateCommissionValue(
                commissionProd,
                prod,
                countService,
              );
              totalCalculateComm =
                  commissionProd.calculatePerCount??false
                      ? _calculateComm
                      : _currentProd.commissionSimpleVan + _calculateComm;
              _currentProd.commissionSimpleVan = totalCalculateComm;
            } else {
              countService = (_currentProd.countSpecialVan + 1).toDouble();
              _currentProd.countSpecialVan = countService.toInt();
              _currentProd.totalSpecialVal =
                  _currentProd.totalSpecialVal + (prod.price??0);
              _calculateComm = _calculateCommissionValue(
                commissionProd,
                prod,
                countService,
              );
              totalCalculateComm =
                  commissionProd.calculatePerCount??false
                      ? _calculateComm
                      : _currentProd.commissionSpecialVan + _calculateComm;
              _currentProd.commissionSpecialVan = totalCalculateComm;
            }
          }
          break;
        case 3:
          {
            //Moto
            if (prod.productType == 'Sencillo') {
              countService = (_currentProd.countSimpleMoto + 1).toDouble();
              _currentProd.countSimpleMoto = countService.toInt();
              _currentProd.totalSimpleMoto =
                  _currentProd.totalSimpleMoto + (prod.price??0);
              _calculateComm = _calculateCommissionValue(
                commissionProd,
                prod,
                countService,
              );
              totalCalculateComm =
                  commissionProd.calculatePerCount??false
                      ? _calculateComm
                      : _currentProd.commissionSimpleMoto + _calculateComm;
              _currentProd.commissionSimpleMoto = totalCalculateComm;
            } else {
              countService = (_currentProd.countSpecialMoto + 1).toDouble();
              _currentProd.countSpecialMoto = countService.toInt();
              _currentProd.totalSpecialMoto =
                  _currentProd.totalSpecialMoto + (prod.price??0);
              _calculateComm = _calculateCommissionValue(
                commissionProd,
                prod,
                countService,
              );
              totalCalculateComm =
                  commissionProd.calculatePerCount??false
                      ? _calculateComm
                      : _currentProd.commissionSpecialMoto + _calculateComm;
              _currentProd.commissionSpecialMoto = totalCalculateComm;
            }
          }
          break;
        case 4:
          {
            //Bicicleta
            if (prod.productType == 'Sencillo') {
              countService = (_currentProd.countSimpleBicycle + 1).toDouble();
              _currentProd.countSimpleBicycle = countService.toInt();
              _currentProd.totalSimpleBicycle =
                  _currentProd.totalSimpleBicycle + (prod.price??0);
              _calculateComm = _calculateCommissionValue(
                commissionProd,
                prod,
                countService,
              );
              totalCalculateComm =
                  commissionProd.calculatePerCount??false
                      ? _calculateComm
                      : _currentProd.commissionSimpleBicycle + _calculateComm;
              _currentProd.commissionSimpleBicycle = totalCalculateComm;
            } else {
              countService = (_currentProd.countSpecialBicycle + 1).toDouble();
              _currentProd.countSpecialBicycle = countService.toInt();
              _currentProd.totalSpecialBicycle =
                  _currentProd.totalSpecialBicycle + (prod.price??0);
              _calculateComm = _calculateCommissionValue(
                commissionProd,
                prod,
                countService,
              );
              totalCalculateComm =
                  commissionProd.calculatePerCount??false
                      ? _calculateComm
                      : _currentProd.commissionSpecialBicycle + _calculateComm;
              _currentProd.commissionSpecialBicycle = totalCalculateComm;
            }
          }
          break;
      }
    } else {
      countService = (1 / (prod.countOperatorsInvoice??0));
      _currentProd.countSharedServices = _currentProd.countSharedServices + 1;
      _currentProd.totalSharedValue =
          _currentProd.totalSharedValue +
          ((prod.price??0) / (prod.countOperatorsInvoice??0));
      _calculateComm = _calculateCommissionValue(
        commissionProd,
        prod,
        countService,
      );
      _currentProd.commissionSharedServices =
          commissionProd.calculatePerCount??false
              ? _calculateComm
              : _currentProd.commissionSharedServices + _calculateComm;
    }

    _currentProd.totalCommission =
        _currentProd.commissionSimpleAuto +
        _currentProd.commissionSpecialAuto +
        _currentProd.commissionSimpleVan +
        _currentProd.commissionSpecialVan +
        _currentProd.commissionSimpleMoto +
        _currentProd.commissionSpecialMoto +
        _currentProd.commissionSimpleBicycle +
        _currentProd.commissionSpecialBicycle +
        _currentProd.commissionSharedServices;

    if (prod.countOperatorsInvoice == 1) {
      if (prod.productType == 'Sencillo') {
        _currentProd.countSimpleServices = _currentProd.countSimpleServices + 1;
        _currentProd.totalSimpleValue =
            _currentProd.totalSimpleValue + (prod.price??0);
      } else {
        _currentProd.countSpecialServices =
            _currentProd.countSpecialServices + 1;
        _currentProd.totalSpecialValue =
            _currentProd.totalSpecialValue + (prod.price??0);
      }
    }
    return _currentProd;
  }

  ///TODO Metodo usado para calcular la comisisón, se puede eliminar, la comisión ya se calcula al guardar la factura (se puede eliminar despues de hacer test en sede)
  double _calculateCommissionValue(
    Commission commissionProd,
    Product prod,
    double countService,
  ) {
    bool isNormal = false;
    double calculateComm = 0;
    if ((commissionProd.commissionThreshold??0) > 0) {
      if ((prod.price??0) <= (commissionProd.commissionThreshold??0)) {
        if (commissionProd.calculatePerCount??false) {
          calculateComm =
              commissionProd.isValue??false
                  ? countService * (commissionProd.valueBeforeThreshold??0)
                  : (countService * (commissionProd.valueBeforeThreshold??0)) /
                      100;
        } else {
          calculateComm =
              commissionProd.isValue??false
                  ? (prod.price??0) * (commissionProd.valueBeforeThreshold??0)
                  : ((prod.price??0) * (commissionProd.valueBeforeThreshold??0)) / 100;
        }
      } else {
        isNormal = true;
      }
    } else {
      isNormal = true;
    }
    if (isNormal) {
      if (commissionProd.calculatePerCount??false) {
        calculateComm =
            commissionProd.isValue??false
                ? countService * (commissionProd.value??0)
                : (countService * (commissionProd.value??0)) / 100;
      } else {
        calculateComm =
            commissionProd.isValue??false
                ? (prod.price??0) * (commissionProd.value??0)
                : ((prod.price??0) * (commissionProd.value??0)) / 100;
      }
    }
      return calculateComm;
  }

  ProductsCardDetail _startCardDetail(Product prod, int countInvoices) {
    var createdDate = prod.dateAdded!.toDate();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String dateFormatted = formatter.format(createdDate);
    ProductsCardDetail productDetail = ProductsCardDetail(
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      dateFormatted,
      countInvoices
    );
    return productDetail;
  }

  void _downloadReport() async {
    int count = 0;
    try {
      List<Invoice> _listInvoicesReport =
          _listInvoices
              .where((f) => !(f.cancelledInvoice??false) && (f.invoiceClosed??false))
              .toList();
      if (_listInvoicesReport.length > 0) {
        MessagesUtils.showAlertWithLoading(
          context: context,
          title: 'Generando reporte',
        ).show();

        int _maxCountOperators = 0;
        _listInvoicesReport.forEach((itemInvoice) {
          if ((itemInvoice.countOperators ?? 0) > _maxCountOperators)
            _maxCountOperators = itemInvoice.countOperators??0;
        });

        var excel = Excel.createExcel();
        var sheetObject = excel["Sheet1"];

        List<String> header = [
          "Fecha del servicio",
          "Sede",
          "Factura",
          "Valor total",
          "Comisión total del servicio",
          "Cantidad de operadores",
          "Comisión por operador",
          "Operadores",
        ];
        for (var i = 1; i <= _maxCountOperators; i++) {
          header.add("Operador " + i.toString());
        }
        sheetObject.appendRow(header.map((e) => TextCellValue(e)).toList());
        _listInvoicesReport.forEach((item) {
          count++;
          List<CellValue> row = [
            TextCellValue(
              item.creationDate != null
                  ? formatter.format(item.creationDate!.toDate())
                  : '',
            ),
            TextCellValue(item.locationName ?? ''),
            TextCellValue(item.consecutive?.toString()??''),
            IntCellValue((item.totalPrice??0).toInt()),
            DoubleCellValue(item.totalCommission ?? 0),
            IntCellValue(item.countOperators ?? 0),
            DoubleCellValue(((item.totalCommission ?? 0) / (item.countOperators??0))),
            TextCellValue(item.operatorsSplit ?? ''),
          ];
          item.operatorUsers?.forEach((itemOpp) {
            row.add(TextCellValue(itemOpp.name));
          });
          sheetObject.appendRow(row.cast<CellValue?>());
        });

        excel.rename("Sheet1", "Hoja1");

        String outputFile =
            "/storage/emulated/0/Download/ReporteProductividad_${_selectedLocation.locationName}.xlsx";
        var encodedExcel = await excel.encode();
        if (encodedExcel != null) {
          File(path_prov.join(outputFile))
            ..createSync(recursive: true)
            ..writeAsBytesSync(encodedExcel);
        }

        Navigator.pop(context); //Close popUp Save
        Fluttertoast.showToast(
          msg: "Su reporte ha sido descargado en: ${outputFile}",
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (_error) {
      print('$_error');
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: "Error generando el informe: Linea $count  $_error",
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  ///TODO este metodo se llama para agregar los operadores a una lista en la misma factura
  void _updateInvoices(List<Invoice> _invoice) async {
    _blocReports.updateInfoOperatorsInvoices(_invoice);
    //_updateProductsCommission(_invoice);
    //_blocReports.updateInfoProductsInvoice(_invoice);
    //_blocReports.addIdToProductInvoice(_invoice);
  }

  ///TODO metodo para calcular la comisión en el mismo producto de la cotización
  void _updateProductsCommission(List<Invoice> _invoice) async {
    List<Commission> commissionsList =
        await _blocCommission.getAllCommissions();
    _invoice.forEach((invo) async {
      if ((invo.invoiceProducts?.length??0) > 0) {
        List<Product> _productsInvoice = [];
        List<SysUser> _operatorsToSave = [];
        double _totalCommission = 0;
        invo.invoiceProducts?.forEach((prod) {
          if ((prod.productCommission ?? 0) == 0) {
            var commissionProd = commissionsList.firstWhere(
              (c) =>
                  c.productType == prod.productType &&
                  c.uidVehicleType == invo.uidVehicleType,
              orElse: () => new Commission(),
            );
            print(commissionProd);
            bool isNormal = false;
            double calculateComm = 0;
            if ((commissionProd.commissionThreshold??0) > 0) {
              if ((prod.price??0) <= (commissionProd.commissionThreshold??0)) {
                if (commissionProd.calculatePerCount??false) {
                  calculateComm =
                      commissionProd.isValue??false
                          ? (commissionProd.valueBeforeThreshold??0)
                          : (commissionProd.valueBeforeThreshold??0) / 100;
                } else {
                  calculateComm =
                      commissionProd.isValue??false
                          ? (prod.price??0) * (commissionProd.valueBeforeThreshold??0)
                          : ((prod.price??0) * (commissionProd.valueBeforeThreshold??0)) /
                              100;
                }
              } else {
                isNormal = true;
              }
            } else {
              isNormal = true;
            }
            if (isNormal) {
              if (commissionProd.calculatePerCount??false) {
                calculateComm =
                    commissionProd.isValue??false
                        ? (commissionProd.value??0)
                        : (commissionProd.value??0) / 100;
              } else {
                calculateComm =
                    commissionProd.isValue??false
                        ? (prod.price??0) * (commissionProd.value??0)
                        : ((prod.price??0) * (commissionProd.value??0)) / 100;
              }
            }
                      Product copyProd = Product.copyProductInvoiceWith(
              origin: prod,
              commission: calculateComm,
            );
            _productsInvoice.add(copyProd);
            _totalCommission = _totalCommission + calculateComm;
          }
        });

        if (_totalCommission > 0) {
          invo.operatorUsers?.forEach((operator) {
            var operatorSave = SysUser.copyUserOperatorToSaveInvoice(
              id: operator.id,
              name: operator.name,
              operatorCommission: _totalCommission / (invo.countOperators??0),
            );
            _operatorsToSave.add(operatorSave);
          });
          Invoice invoiceUpdate = Invoice.copyWith(
            origin: invo,
            listProducts: _productsInvoice,
            totalCommission: _totalCommission,
            listOperators: _operatorsToSave,
          );
          await _blocInvoice.saveInvoice(invoiceUpdate);
        }
      }
    });
  }
}
