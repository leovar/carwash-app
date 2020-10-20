
import 'dart:ffi';

import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/repository/invoice_repository.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/reports/repository/reports_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class BlocReports implements Bloc {
  final _reportsRepository = ReportsRepository();
  final _invoiceRepository = InvoiceRepository();
  BlocInvoice _blocInvoice = BlocInvoice();

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
      if(item.locationName == 'Viva Palmas') {
        List<Product> listProducts = await _invoiceRepository.getInvoiceProducts(item.id);
        final _invoice = Invoice.copyWith(
          origin: item,
          countProducts: listProducts.where((f) => !f.isAdditional).length,
          countAdditionalProducts: listProducts.where((f) => f.isAdditional).length,
        );
        DocumentReference ref = await _invoiceRepository.updateInvoiceData(_invoice);
      }
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

  @override
  void dispose() {
  }

}