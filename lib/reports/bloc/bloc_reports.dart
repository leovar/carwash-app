
import 'dart:ffi';

import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/repository/invoice_repository.dart';
import 'package:car_wash_app/product/bloc/product_bloc.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/reports/repository/reports_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  void updateInfoInvoices(List<Invoice> invoices) async {
    invoices.forEach((item) async {
      List<Product> listProducts = await _invoiceRepository.getInvoiceProducts(item.id);
      final _invoice = Invoice.copyWith(
        origin: item,
        countProducts: listProducts.where((f) => !f.isAdditional).length,
        countAdditionalProducts: listProducts.where((f) => f.isAdditional).length,
      );
      DocumentReference ref = await _invoiceRepository.updateInvoiceData(_invoice);
    });
  }

  void updateInfoProductsInvoice(List<Invoice> invoices) async {
    invoices.forEach((item) async {
      final listInvoiceProducts = await _invoiceRepository.getProductsByIdInvoice(item.id);
      listInvoiceProducts.forEach((invProduct) async {
        if (invProduct.id != null) {
          final product = await _blocProduct.getProductById(invProduct.id);
          final newProd = Product.copyProductInvoiceWith(origin: invProduct, productType: product.productType, productInvoiceId: invProduct.productInvoiceId);
          _blocInvoice.updateInvoiceProduct(item.id, newProd);
        } else {
          String productTypeAdditional = 'Sencillo';
          if(item.uidVehicleType.toString().contains('1') || item.uidVehicleType.toString().contains('2')) {
            productTypeAdditional = 'Especial';
          }
          final newProd = Product.copyProductInvoiceWith(origin: invProduct, productType: productTypeAdditional, productInvoiceId: invProduct.productInvoiceId);
          _blocInvoice.updateInvoiceProduct(item.id, newProd);
        }
      });
    });
  }

  Future<List<Product>> getProductsByInvoicesReport(var invoices) async {
    List<Product> productList = [];
    int countInvoices = 0;
    for (var item in invoices) {
      countInvoices++;
      List<Product> products = await _blocInvoice.getProductsByInvoice(item.id);
      productList.addAll(products);
      if (countInvoices == invoices.length) {
        return productList;
      }
    }
  }

  Future<List<Invoice>> getInvoiceAndProductsReport(List<DocumentSnapshot> invoicesListSnapshot) async {
    List<Invoice> invoices = _reportsRepository.buildListProductivityReport(invoicesListSnapshot);
    List<Invoice> newInvoicesList = <Invoice>[];
    List<Product> productList = [];
    int countInvoices = 0;
    for (var item in invoices) {
      countInvoices++;
      List<Product> products = await _blocInvoice.getProductsByInvoice(item.id);
      final _invoiceData = Invoice.copyWith(
        origin: item, listProducts: products
      );
      newInvoicesList.add(_invoiceData);
      productList.addAll(products);
      if (countInvoices == invoices.length) {

        return newInvoicesList; // productList;
      }
    }
  }


  @override
  void dispose() {
  }

}