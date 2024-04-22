
import 'dart:ffi';
import 'dart:io';

import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/repository/invoice_repository.dart';
import 'package:car_wash_app/product/bloc/product_bloc.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/reports/repository/reports_repository.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
    List<Invoice> invoices = _reportsRepository.buildListProductivityReport(invoicesListSnapshot);
    return invoices;
  }

  //TODO metodo temporal para solucionar error con los id de los servicios dentro de las facturas
  void updateInfoOperatorsInvoices(List<Invoice> invoices) async {
    invoices.forEach((item) async {
      if (item.userOperatorName != null) {
        if (item.operatorUsers != null) {
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
        } else {
          //creo la lista de operadores con el operador y el contador y actualizo la factura
          List<User> _operatorsExist = [];
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

      /*List<Product> listProducts = await _invoiceRepository.getInvoiceProductsTemporal(item.id);
      if (listProducts.length > 0) {
        var _invoice = Invoice.copyWith(
          origin: item,
          countProducts: listProducts.where((f) => !f.isAdditional).length,
          countAdditionalProducts: listProducts.where((f) => f.isAdditional).length,
          listProducts: listProducts,
        );
        if (item.invoiceProducts.length == 0) {
          DocumentReference ref = await _invoiceRepository.updateInvoiceData(_invoice);
        }
      }*/
    });
  }

  Future<List<Invoice>> getListCustomerInvoicesByLocation(DocumentReference locationReference, DateTime dateInit, DateTime dateFinal) async {
    return await _reportsRepository.getCustomerInvoicesByLocation(locationReference, dateInit, dateFinal);
  }

  //TODO metodo temporal para solucionar error con los id de los servicios dentro de las facturas
  Future<int> updateInfoProductsInvoice(List<Invoice> invoices) async {
    var countData = 0;
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
    return countData;
  }

  //TODO metodo temporal para solucionar error con los id de los servicios dentro de las facturas
  void addIdToProductInvoiceTemp(List<Invoice> invoices) async {
    List<Invoice> invoicesList = invoices.where((item) => item.invoiceProducts.length > 0).toList();

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
    });


    /*
    List<Invoice> allInvoices = await _reportsRepository.getAllInvoices();
    allInvoices.forEach((element) async {
      List<Product> productsInvoice = await _invoiceRepository.getProductsByIdInvoice(element.id);
      productsInvoice.forEach((item) {
        if (item.id == 'bpdtndDhpviCzpfipQxi') {
          print('bpdtndDhpviCzpfipQxi');
        }
        if (item.id == 'sDXNlRNGOBbIXody8LS7') {
          print('sDXNlRNGOBbIXody8LS7');
        }
      });
    });
    */

  }

  @override
  void dispose() {
  }
}