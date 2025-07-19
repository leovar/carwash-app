import 'package:car_wash_app/customer/bloc/bloc_customer.dart';
import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/repository/invoice_repository.dart';
import 'package:car_wash_app/product/bloc/product_bloc.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/reports/model/earnings_card_detail.dart';
import 'package:car_wash_app/reports/repository/reports_repository.dart';
import 'package:car_wash_app/user/model/sysUser.dart';
import 'package:car_wash_app/vehicle/bloc/bloc_vehicle.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:path/path.dart';

class BlocReports implements Bloc {
  final _reportsRepository = ReportsRepository();
  final _invoiceRepository = InvoiceRepository();
  BlocInvoice _blocInvoice = BlocInvoice();
  ProductBloc _blocProduct = ProductBloc();
  BlocCustomer _blocCustomer = BlocCustomer();
  BlocVehicle _blocVehicle = BlocVehicle();

  // Casos de uso
  //1. Obtener datos Informe productividad

  Stream<QuerySnapshot> productivityReportListStream(
    DocumentReference locationReference,
    DateTime dateInit,
    DateTime dateFinal,
    String companyId,
  ) {
    return _reportsRepository.getListProductivityReportStream(
      locationReference,
      dateInit,
      dateFinal,
      companyId,
    );
  }

  List<Invoice> buildProductivityReportList(
      List<DocumentSnapshot> invoicesListSnapshot) {
    List<Invoice> invoices =
        _reportsRepository.buildInvoiceListReport(invoicesListSnapshot);
    return invoices;
  }

  Stream<QuerySnapshot> earningsReportListStream(
      DateTime dateInit, DateTime dateFinal, String companyId) {
    return _reportsRepository.getListEarningsReportStream(
        dateInit, dateFinal, companyId);
  }

  List<Invoice> buildEarningsReportList(
      List<DocumentSnapshot> invoicesListSnapshot) {
    List<Invoice> invoices =
        _reportsRepository.buildInvoiceListReport(invoicesListSnapshot);
    return invoices;
  }

  List<EarningsCardDetail> buildEarningCards(List<Invoice> _invoices) {
    List<EarningsCardDetail> _cardList = [];
    try {
      _invoices.forEach((item) {
        EarningsCardDetail? detailInfo = _cardList.length > 0
            ? _cardList.firstWhere((x) => x.locationName == item.locationName,
                orElse: () => new EarningsCardDetail('', 0, 0, []))
            : null;
        if (detailInfo == null || detailInfo.locationName == '') {
          List<Invoice> invoicesPerLocation = [];
          invoicesPerLocation.add(item);
          final cardData = EarningsCardDetail(
            item.locationName ?? '',
            (item.countProducts ?? 0) + (item.countAdditionalProducts ?? 0),
            item.totalPrice ?? 0,
            invoicesPerLocation,
          );
          _cardList.add(cardData);
        } else {
          detailInfo.countServices = detailInfo.countServices +
              ((item.countProducts ?? 0) + (item.countAdditionalProducts ?? 0));
          detailInfo.totalPrice =
              detailInfo.totalPrice + (item.totalPrice ?? 0);
          List<Invoice> listGet = detailInfo.invoicesList;
          listGet.add(item);
          int indexData = _cardList.indexOf(detailInfo);
          _cardList[indexData] = detailInfo;
        }
      });
      return _cardList;
    } catch (_error) {
      print(_error);
      Fluttertoast.showToast(
          msg: "Error generando el informe: $_error",
          toastLength: Toast.LENGTH_LONG);
      return _cardList;
    }
  }

  Future<List<Invoice>> getListCustomerInvoicesByLocation(
      DocumentReference locationReference,
      DateTime dateInit,
      DateTime dateFinal) async {
    return await _reportsRepository.getCustomerInvoicesByLocation(
        locationReference, dateInit, dateFinal);
  }

  //TODO metodo temporal para crearles a todas las facturas el id de la compania
  void updateInfoCompanyIdInvoices() async {
    try {
      List<Invoice> invoicesList = await _reportsRepository.getAllInvoices();
      List<Invoice> invoiceFilter = invoicesList
          .where((item) => item.locationName == 'PRUEBAS' && item.companyId.isEmpty).toList();

      invoiceFilter.forEach((item) async {
        if (item.companyId.isEmpty) {
          Invoice invoice = Invoice.copyWith(
            origin: item,
            companyId: 'gtixUTsEImKUuhdSCwKX',
          );
          await _blocInvoice.updateCompanyInvoice(invoice);
        }
      });
      print(invoiceFilter);
    } catch (_error) {
      print(_error);
      Fluttertoast.showToast(
          msg: "Error corrigiendo compania: $_error",
          toastLength: Toast.LENGTH_LONG);
    }
  }

  void updateCompanyInProducts() async {
    List<Product> products = await _blocProduct.getAllProducts();
    products.forEach((item) async {
      if ((item.companyId ?? '').isEmpty) {
        Product prod = Product.copyWith(
          origin: item,
          companyId: 'gtixUTsEImKUuhdSCwKX',
        );
        _blocProduct.updateProduct(prod);
      }
    });
    print(products);
  }

  //TODO metodo temporal para asignarle companyId a todos los clientes
  Future<String?> updateCustomersCompany() async {
    const int batchSize = 100; // Tamaño del lote
    int totalUpdated = 0;
    DocumentSnapshot? lastDocument;
    try {
      do {
        QuerySnapshot customerSnap =
            await _blocCustomer.getAllCustomers(batchSize, lastDocument);

        if (customerSnap.docs.isEmpty) {
          break;
        }

        List<QueryDocumentSnapshot> listDocs = [];
        for (final doc in customerSnap.docs) {
          final data = doc.data();
          if (data is Map<String, dynamic>) {
            if (!data.containsKey('companyId') || data['companyId'] == null) {
              listDocs.add(doc);
            }
          }
        }

        if (listDocs.length > 0) {
          await _blocCustomer.updateCustomerBatch(customerSnap.docs, 'gtixUTsEImKUuhdSCwKX');
        }

        totalUpdated += customerSnap.docs.length;
        lastDocument = customerSnap.docs.last;
        await Future.delayed(Duration(milliseconds: 100));
      } while (true);

      Fluttertoast.showToast(
          msg: "Proceso completado con ${totalUpdated} Registros",
          toastLength: Toast.LENGTH_LONG);
      return totalUpdated.toString();
    } catch (_error) {
      print(_error);
    }
    return null;
  }

  Future<String?> updateVehiclesCompany() async {
    const int batchSize = 200; // Tamaño del lote
    int totalUpdated = 0;
    DocumentSnapshot? lastDocument;
    try {
      do {
        QuerySnapshot vehiclesSnap = await _blocVehicle.getAllVehicles(batchSize, lastDocument);

        if (vehiclesSnap.docs.isEmpty) {
          break;
        }

        List<QueryDocumentSnapshot> listDocs = [];
        for (final doc in vehiclesSnap.docs) {
          final data = doc.data();
          if (data is Map<String, dynamic>) {
            if (!data.containsKey('companyId') || data['companyId'] == null) {
              listDocs.add(doc);
            }
          }
        }

        if (listDocs.length > 0) {
          await _blocVehicle.updateVehiclesBatch(vehiclesSnap.docs, 'gtixUTsEImKUuhdSCwKX');
        }

        totalUpdated += vehiclesSnap.docs.length;
        lastDocument = vehiclesSnap.docs.last;
        await Future.delayed(Duration(milliseconds: 100));
      } while (true);

      Fluttertoast.showToast(
          msg: "Proceso completado con ${totalUpdated} Registros",
          toastLength: Toast.LENGTH_LONG);
      return totalUpdated.toString();
    } catch (_error) {
      print(_error);
    }
    return null;
  }

  //TODO metodo para actualizar compania en las facturas, eliminar cuando la app este actualizada en todos los dispositivos
  Future<String?> updateCompanyIdInInvoices() async {
    const int batchSize = 500; // Tamaño del lote
    int totalUpdated = 0;
    int totalProcessed = 0;
    DocumentSnapshot? lastDocument;
    try {
      do {
        QuerySnapshot invoicesSnap = await _blocInvoice.getAllInvoicesBatch(batchSize, lastDocument);

        if (invoicesSnap.docs.isEmpty) {
          break;
        }

        List<QueryDocumentSnapshot> listDocs = [];
        for (final doc in invoicesSnap.docs) {
          final data = doc.data();
          if (data is Map<String, dynamic>) {
            if (!data.containsKey('companyId') || data['companyId'] == null) {
              listDocs.add(doc);
            }
          }
        }

        if (listDocs.length > 0) {
          await _blocInvoice.updateInvoicesBatch(invoicesSnap.docs, 'gtixUTsEImKUuhdSCwKX');
        }

        totalUpdated += invoicesSnap.docs.length;
        lastDocument = invoicesSnap.docs.last;
        totalProcessed += listDocs.length;

        await Future.delayed(Duration(milliseconds: 100));
      } while (true);

      Fluttertoast.showToast(
          msg: "Proceso completado con ${totalUpdated} Registros",
          toastLength: Toast.LENGTH_LONG);
      return totalUpdated.toString() + ' - ' + totalProcessed.toString();
    } catch (_error) {
      print(_error);
    }
    return null;
  }

  //TODO metodo temporal para pasar el operador de la factura a una lista de operadores dentro de la factura
  void updateInfoOperatorsInvoices(List<Invoice> invoices) async {
    /*try {
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
            List<SysUser> _operatorsExist = item.operatorUsers;
            var oppInsert = SysUser.copyUserOperatorToSaveInvoice(
              id: item.userOperator.id,
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
    }*/
  }

  //TODO metodo temporal para solucionar error con los id de los servicios dentro de las facturas
  /*Future<int> updateInfoProductsInvoice(List<Invoice> invoices) async {
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
  }*/

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
  void dispose() {}
}
