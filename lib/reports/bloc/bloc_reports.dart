

import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/repository/invoice_repository.dart';
import 'package:car_wash_app/product/bloc/product_bloc.dart';
import 'package:car_wash_app/reports/model/earnings_card_detail.dart';
import 'package:car_wash_app/reports/repository/reports_repository.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class BlocReports implements Bloc {
  final _reportsRepository = ReportsRepository();
  final _invoiceRepository = InvoiceRepository();
  BlocInvoice _blocInvoice = BlocInvoice();
  ProductBloc _blocProduct = ProductBloc();

  // Casos de uso
  //1. Obtener datos Informe productividad

  Stream<QuerySnapshot> productivityReportListStream(
      DocumentReference locationReference,
      DateTime dateInit,
      DateTime dateFinal,
      ) {
    return _reportsRepository.getListProductivityReportStream(
      locationReference,
      dateInit,
      dateFinal,
    );
  }

  List<Invoice> buildProductivityReportList(List<DocumentSnapshot> invoicesListSnapshot) {
    List<Invoice> invoices = _reportsRepository.buildInvoiceListReport(invoicesListSnapshot);
    return invoices;
  }

  Stream<QuerySnapshot> earningsReportListStream(DateTime dateInit, DateTime dateFinal,) {
    return _reportsRepository.getListEarningsReportStream(dateInit, dateFinal);
  }

  List<Invoice> buildEarningsReportList(List<DocumentSnapshot> invoicesListSnapshot) {
    List<Invoice> invoices = _reportsRepository.buildInvoiceListReport(invoicesListSnapshot);
    return invoices;
  }

  List<EarningsCardDetail> buildEarningCards(List<Invoice> _invoices) {
    List<EarningsCardDetail> _cardList = [];
    try {
      _invoices.forEach((item) {
        EarningsCardDetail detailInfo = _cardList.length > 0
            ? _cardList.firstWhere((x) => x.locationName == item.locationName, orElse: () => null)
            : null;
        detailInfo.countServices = detailInfo.countServices + (item.countProducts + item.countAdditionalProducts);
        detailInfo.totalPrice = detailInfo.totalPrice + item.totalPrice;
        List<Invoice> listGet = detailInfo.invoicesList;
        listGet.add(item);
        int indexData = _cardList.indexOf(detailInfo);
        _cardList[indexData] = detailInfo;
            });
      return _cardList;
    } catch(_error) {
      print(_error);
      Fluttertoast.showToast(
          msg: "Error generando el informe: $_error",
          toastLength: Toast.LENGTH_LONG);
      return _cardList;
    }
  }

  //TODO metodo temporal para pasar el operador de la factura a una lista de operadores dentro de la factura
  void updateInfoOperatorsInvoices(List<Invoice> invoices) async {
    try {
      invoices.forEach((item) async {
        if (item.userOperatorName.isNotEmpty) {
          //valido que el operador unico no este creado en la lista
          bool exist = false;
          for (var elm in item.operatorUsers) {
            if (elm.name == item.userOperatorName) {
              exist = true;
              break;
            }
          }
          if (!exist) {
            List<User> _operatorsExist = item.operatorUsers;
            var oppInsert = User.copyUserOperatorToSaveInvoice(
              id: item.userOperator.documentID,
              name: item.userOperatorName,
            );
            _operatorsExist.add(oppInsert);
            int _countOperators = _operatorsExist.length;
            Invoice invoice = Invoice.copyWith(
              origin: item,
              listOperators: _operatorsExist,
              countOperators: _countOperators,
            );
            await _blocInvoice.saveInvoice(invoice);
          }
                }
      });
    } catch(_error) {
      print(_error);
      Fluttertoast.showToast(msg: "Error corrigiendo operadores: $_error", toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<List<Invoice>> getListCustomerInvoicesByLocation(DocumentReference locationReference, DateTime dateInit, DateTime dateFinal) async {
    return await _reportsRepository.getCustomerInvoicesByLocation(locationReference, dateInit, dateFinal);
  }

  //TODO metodo temporal para solucionar error con los id de los servicios dentro de las facturas
  Future<int> updateInfoProductsInvoice(List<Invoice> invoices) async {
    /*var countData = 0;
    invoices.forEach((item) async {
      final listInvoiceProducts = await _invoiceRepository.getProductsByIdInvoice(item.id);
      listInvoiceProducts.forEach((invProduct) async {
        if (invProduct.id != null) {
          final product = await _blocProduct.getProductById(invProduct.id);
          final newProd = Product.copyProductInvoiceWith(origin: invProduct, productType: product.productType, productInvoiceId: invProduct.productInvoiceId);
          await _blocInvoice.updateInvoiceProduct(item.id, newProd);
          countData ++;
        } else {
          String productTypeAdditional = 'Sencillo';
          if(item.uidVehicleType.toString().contains('1') || item.uidVehicleType.toString().contains('2')) {
            productTypeAdditional = 'Especial';
          }
          final newProd = Product.copyProductInvoiceWith(origin: invProduct, productType: productTypeAdditional, productInvoiceId: invProduct.productInvoiceId);
          await _blocInvoice.updateInvoiceProduct(item.id, newProd);
          countData ++;
        }
      });
    });
    return countData;*/
  }

  //TODO metodo temporal para solucionar error con los id de los servicios dentro de las facturas
  void addIdToProductInvoiceTemp(List<Invoice> invoices) async {
    /*List<Invoice> invoicesList = invoices.where((item) => item.invoiceProducts.length > 0).toList();

    List<Product> productos = await _blocProduct.getAllProducts();
    List<Invoice> invoiceData = [];
    invoicesList.forEach((f) {
      List<Product> productsUpdated = [];
      bool isupdate = false;
      f.invoiceProducts.forEach((d) {
        if (!d.isAdditional && d.id == null) {
          List<Product> newProduct = productos.where((e) => e.productName == d.productName).toList();
          Product selectProduct = newProduct.firstWhere((item) => item.vehicleTypeUid == f.uidVehicleType);
          Product prodUpdate = Product.copyProductInvoiceWith(origin: d, id: selectProduct.id);
          productsUpdated.add(prodUpdate);
          isupdate = true;
        } else {
          productsUpdated.add(d);
        }
      });
      var _invoice = Invoice.copyWith(
        origin: f,
        listProducts: productsUpdated,
      );
      if (isupdate) {
        print('ACTUALIZO LA FACTURA # ${_invoice.consecutive.toString()}');
        _invoiceRepository.updateInvoiceData(_invoice);
      }
    });*/
  }

  @override
  void dispose() {
  }
}