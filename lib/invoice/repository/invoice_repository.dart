import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:car_wash_app/invoice/model/additional_product.dart';
import 'package:car_wash_app/invoice/model/configuration.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/payment_methods/model/payment_methods.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/user/model/sysUser.dart';
import 'package:car_wash_app/vehicle_type/model/brand.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

class InvoiceRepository {
  String uid = '';

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _authApi = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final _storageReference = FirebaseStorage.instance;

  /// Save and Update Invoice
  Future<DocumentReference> updateInvoiceData(Invoice invoice) async {
    var jsonInvoice = invoice.toJson();
    var mapProducts = [];
    invoice.invoiceProducts?.forEach((element) {
      var mapProduct = Product().toJsonInvoiceProduct(
        element.productName??'',
        element.price??0,
        element.ivaPercent??0,
        element.isAdditional??false,
        element.id??'',
        element.productType??'',
        element.serviceTime??0,
        element.productCommission??0,
      );
      mapProducts.add(mapProduct);
    });
    jsonInvoice['invoiceProducts'] = mapProducts;
    var mapOperators = [];
    invoice.operatorUsers?.forEach((item) {
      var mapOperator = SysUser.toJsonInvoiceOperator(
        item.id,
        item.name,
        item.operatorCommission,
      );
      mapOperators.add(mapOperator);
    });
    jsonInvoice['operatorUsers'] = mapOperators;
    DocumentReference ref =
        _db.collection(FirestoreCollections.invoices).doc(invoice.id);
    ref.set(jsonInvoice, SetOptions( merge: true ));
    return ref;
  }

  /// Save invoice images in firebase storage
  Future<TaskSnapshot> uploadImageInvoice(String path, File imageFile) async {
    final storageUploadTask = _storageReference.ref().child(path).putFile(
          imageFile,
          SettableMetadata(
            contentType: 'image/jpeg',
          ),
        );
    return await storageUploadTask.whenComplete((){});
  }

  ///Save Firm Image in firebase storage
  Future<TaskSnapshot> uploadImageFirmInvoice(
      String path, Uint8List imageFile) async {
    final storageUploadTask = _storageReference.ref().child(path).putData(
          imageFile,
          SettableMetadata( contentType: 'image/jpeg' ),
        );
    return await storageUploadTask.whenComplete((){});
  }

  /// Save images URL in subcollection invoice
  Future<DocumentReference<Map<String, dynamic>>> updateInvoiceImages(
      String invoiceId, String invoiceImage, String imagePath) async {
    return await
        _db
        .collection(FirestoreCollections.invoices)
        .doc(invoiceId)
        .collection('images')
        .add({'imageUrl': invoiceImage, 'imagePath': imagePath});
  }

  ///Get Operators list by Location
  Stream<QuerySnapshot> getListOperatorsStream(String companyId) {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldCompanyId, isEqualTo: companyId)
        .where(FirestoreCollections.usersFieldIsOperator, isEqualTo: true)
        .where(FirestoreCollections.usersFieldUserActive, isEqualTo: true)
        .snapshots();
    return querySnapshot;
  }

  Stream<QuerySnapshot> getListOperatorsByLocationStream(String idLocation, String companyId) {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldCompanyId, isEqualTo: companyId)
        .where(FirestoreCollections.locations,
            arrayContains:
                _db.doc('${FirestoreCollections.locations}/$idLocation'))
        .where(FirestoreCollections.usersFieldIsOperator, isEqualTo: true)
        .where(FirestoreCollections.usersFieldUserActive, isEqualTo: true)
        .snapshots();
    return querySnapshot;
  }

  List<SysUser> buildOperators(List<DocumentSnapshot> operatorsListSnapshot) {
    List<SysUser> usersList = <SysUser>[];
    operatorsListSnapshot.forEach((p) {
      SysUser loc = SysUser.fromJson(p.data() as Map<String, dynamic>, id: p.id);
      usersList.add(loc);
    });
    return usersList;
  }

/*
  Future<List<SysUser>> getOperatorsUsers() async {
    List<SysUser> userList = <SysUser>[];
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldIsOperator, isEqualTo: true)
        .getDocuments();

    final snapShot = querySnapshot.documents;
    snapShot.forEach((document) {
      SysUser user = SysUser.fromJson(document.data(), id: document.documentID);
      userList.add(user);
    });
    return userList;
  }*/

  /// Get Coordinators list by Location
  Stream<QuerySnapshot> getListCoordinatorStream() {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldIsCoordinator, isEqualTo: true)
        .where(FirestoreCollections.usersFieldUserActive, isEqualTo: true)
        .snapshots();
    return querySnapshot;
  }

  Stream<QuerySnapshot> getListCoordinatorByLocationStream(String idLocation, String companyId) {
    final querySnapshot = this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldCompanyId, isEqualTo: companyId)
        .where(FirestoreCollections.locations,
            arrayContains: _db.doc('${FirestoreCollections.locations}/$idLocation'))
        .where(FirestoreCollections.usersFieldIsCoordinator, isEqualTo: true)
        .where(FirestoreCollections.usersFieldUserActive, isEqualTo: true)
        .snapshots();
    return querySnapshot;
  }

  List<SysUser> buildCoordinator(List<DocumentSnapshot> coordinatorListSnapshot) {
    List<SysUser> usersList = <SysUser>[];
    coordinatorListSnapshot.forEach((p) {
      SysUser loc = SysUser.fromJson(p.data() as Map<String, dynamic>, id: p.id);
      usersList.add(loc);
    });
    return usersList;
  }

  /// Get Brands list by vehicleType
  Stream<QuerySnapshot> getListBrandsStream(int uidVehicleType) {
    var querySnapshot = _db.collection(FirestoreCollections.brands).where(
        FirestoreCollections.brandFieldVehicleType,
        isEqualTo: uidVehicleType);

    return querySnapshot.snapshots();
  }

  Stream<QuerySnapshot> getListAllBrandsStream() {
    var querySnapshot = _db.collection(FirestoreCollections.brands);

    return querySnapshot.snapshots();
  }

  Future<List<String>> getListAllBrandsInvoiceRepo() async {
    List<String> brandList = <String>[];
    var querySnapshot =
        await this._db.collection(FirestoreCollections.brands).get();

    if (querySnapshot.docs.isNotEmpty) {
      querySnapshot.docs.forEach((doc) {
        String brandData = doc.data()['brand'];
        brandList.add(brandData);
      });
    }
    return brandList;
  }

  List<String> buildBrandsInvoice(List<DocumentSnapshot> brandsListSnapshot) {
    List<String> brandsList = <String>[];
    brandsListSnapshot.forEach((p) {
      var data = p.data() as Map<String, dynamic>; // Explicit cast
      String brand = data['brand'];
      brandsList.add(brand);
    });
    return brandsList;
  }

  List<Brand> buildBrands(List<DocumentSnapshot> brandsListSnapshot) {
    List<Brand> brandsList = <Brand>[];
    brandsListSnapshot.forEach((p) {
      Brand _brand = Brand.fromJson(p.data() as Map<String, dynamic>, id: p.id);
      brandsList.add(_brand);
    });
    return brandsList;
  }

  /// Get Brand Reference by brand

  Future<String> getBrandByBrand(String brand) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.brands)
        .where(FirestoreCollections.brandFieldBrand, isEqualTo: brand)
        .get();
    return querySnapshot.docs.first.id;
  }

  Future<List<String>> getBrandReferences(String brandId) async {
    List<String> referencesList = <String>[];
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.brands)
        .doc(brandId)
        .collection(FirestoreCollections.brandReferences)
        .get();

    if (querySnapshot.docs.length > 0) {
      querySnapshot.docs.forEach((doc) {
        String brandReference = doc.data()['reference'];
        referencesList.add(brandReference);
      });
    }
    return referencesList;
  }

  /// Get Colors list by vehicleType (in this moment no filter by vehicle type)
  Stream<QuerySnapshot> getListColorsStream(int uidVehicleType) {
    final querySnapshot =
        this._db.collection(FirestoreCollections.colors).snapshots();
    return querySnapshot;
  }

  List<String> buildColors(List<DocumentSnapshot> colorsListSnapshot) {
    List<String> colorsList = <String>[];
    colorsListSnapshot.forEach((p) {
      var data = p.data() as Map<String, dynamic>; // Explicit cast
      String brand = data['color'];
      colorsList.add(brand);
    });
    return colorsList;
  }

  /*Future<List<SysUser>> getCoordinatorUsers() async {
    List<SysUser> userList = <SysUser>[];
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.users)
        .where(FirestoreCollections.usersFieldIsCoordinator, isEqualTo: true)
        .getDocuments();

    final snapShot = querySnapshot.documents;
    snapShot.forEach((document) {
      SysUser user = SysUser.fromJson(document.data(), id: document.documentID);
      userList.add(user);
    });
    return userList;
  }*/

  /// Get Vehicle Reference
  Future<DocumentReference> getVehicleTypeReference(String vehicleType) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.vehicleType)
        .where(FirestoreCollections.vehicleTypeFieldVehicleType,
            isEqualTo: vehicleType)
        .get();

    final documents = querySnapshot.docs;
    if (documents.length > 0) {
      final documentSnapshot = documents.first;
      return _db
          .collection(FirestoreCollections.vehicleType)
          .doc(documentSnapshot.id);
    }
    return Future.value(null);
  }

  ///Get invoices list from current Month
  Stream<QuerySnapshot> getListInvoicesByMonthStream(
    DocumentReference locationReference,
    DateTime dateInit,
    DateTime dateFinal,
    String placa,
    String consecutive,
    String productTypeSelected,
    String paymentMethod,
    String companyId,
  ) {
    DateTime dateFinalModify =
        DateTime(dateFinal.year, dateFinal.month, dateFinal.day, 23, 59);

    var querySnapshot = this
        ._db
        .collection(FirestoreCollections.invoices)
        .where(FirestoreCollections.invoiceFieldCompanyId, isEqualTo: companyId)
        .where(FirestoreCollections.invoiceFieldCreationDate,
            isGreaterThanOrEqualTo: Timestamp.fromDate(dateInit))
        .where(FirestoreCollections.invoiceFieldCreationDate,
            isLessThanOrEqualTo: Timestamp.fromDate(dateFinalModify))
        .where(FirestoreCollections.invoiceFieldLocation,
            isEqualTo: locationReference);

    if (placa.isNotEmpty) {
      querySnapshot = querySnapshot
          .where(FirestoreCollections.invoiceFieldPlaca, isEqualTo: placa);
    }

    if (consecutive.isNotEmpty) {
      querySnapshot = querySnapshot.where(
          FirestoreCollections.invoiceFieldConsecutive,
          isEqualTo: int.parse(consecutive));
    }

    if (productTypeSelected.isNotEmpty) {
      querySnapshot = querySnapshot.where(
          FirestoreCollections.invoiceFieldHaveSpecialService,
          isEqualTo: productTypeSelected == 'Especial' ? true : false);
    }

    if (paymentMethod.isNotEmpty) {
      querySnapshot = querySnapshot.where(
          FirestoreCollections.invoicePaymentMethod,
          isEqualTo: paymentMethod);
    }

    return querySnapshot.snapshots();
  }

  List<Invoice> buildInvoicesListFromSnapshot(List<DocumentSnapshot> invoicesListSnapshot) {
    List<Invoice> invoicesList = <Invoice>[];
    invoicesListSnapshot.forEach((p) {
      Invoice invoice = Invoice.fromJson(p.data() as Map<String, dynamic>, id: p.id);
      invoicesList.add(invoice);
    });
    return invoicesList;
  }

  /// Get invoices pending for Washing Stream
  Stream<QuerySnapshot> getInvoicesListPendingWashingStream(DocumentReference? locationReference, String companyId) {
    var querySnapshot = this
        ._db
        .collection(FirestoreCollections.invoices)
        .where(FirestoreCollections.invoiceFieldCompanyId, isEqualTo: companyId)
        .where(FirestoreCollections.invoiceFieldLocation, isEqualTo: locationReference)
        .where(FirestoreCollections.invoiceClosed, isEqualTo: false)
        .where(FirestoreCollections.invoiceClosedDate, isNull: true)
        .where(FirestoreCollections.invoiceStartWashing, isEqualTo: false)
        .where(FirestoreCollections.invoiceCancelled, isEqualTo: false);
    return querySnapshot.snapshots();
  }

  /// Get invoices pending for Washing Documents
  Future<List<Invoice>> getInvoicesListPendingWashing(DocumentReference? locationReference, String companyId) async {
    List<Invoice> invoiceList = <Invoice>[];
    var querySnapshot = await this
        ._db
        .collection(FirestoreCollections.invoices)
        .where(FirestoreCollections.invoiceFieldCompanyId, isEqualTo: companyId)
        .where(FirestoreCollections.invoiceFieldLocation, isEqualTo: locationReference)
        .where(FirestoreCollections.invoiceClosed, isEqualTo: false)
        .where(FirestoreCollections.invoiceStartWashing, isEqualTo: false)
        .where(FirestoreCollections.invoiceCancelled, isEqualTo: false).get();
    final documents = querySnapshot.docs;
    if (documents.length > 0) {
      documents.forEach((invoice) {
        Invoice invoiceGet = Invoice.fromJson(invoice.data(), id: invoice.id);
        invoiceList.add(invoiceGet);
      });
    }
    return invoiceList;
  }

  /// Get invoices in washing process Stream
  Stream<QuerySnapshot> getInvoicesListWashingStream(DocumentReference? locationReference, String companyId) {
    var querySnapshot = this
        ._db
        .collection(FirestoreCollections.invoices)
        .where(FirestoreCollections.invoiceFieldLocation, isEqualTo: locationReference)
        .where(FirestoreCollections.invoiceClosed, isEqualTo: false)
        .where(FirestoreCollections.invoiceEndWash, isEqualTo: false)
        .where(FirestoreCollections.invoiceStartWashing, isEqualTo: true);
    return querySnapshot.snapshots();
  }

  Future<List<Invoice>> getInvoicesWashingList(DocumentReference? locationReference, String companyId) async {
    List<Invoice> invoiceList = <Invoice>[];
    var querySnapshot = await this
        ._db
        .collection(FirestoreCollections.invoices)
        .where(FirestoreCollections.invoiceFieldLocation, isEqualTo: locationReference)
        .where(FirestoreCollections.invoiceClosed, isEqualTo: false)
        .where(FirestoreCollections.invoiceEndWash, isEqualTo: false)
        .where(FirestoreCollections.invoiceStartWashing, isEqualTo: true).get();
    final documents = querySnapshot.docs;
    if (documents.length > 0) {
      documents.forEach((element) {
        Invoice invoiceGet = Invoice.fromJson(element.data(), id: element.id);
        invoiceList.add(invoiceGet);
      });
    }
    return invoiceList;
  }

  ///Get last consecutive for location
  Future<int> getLastConsecutiveByLocation(
      DocumentReference locationReference, String companyId) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.invoices)
        .where(FirestoreCollections.invoiceFieldLocation,
            isEqualTo: locationReference)
        .orderBy(FirestoreCollections.invoiceFieldConsecutive, descending: true)
        .limit(3)
        .get();

    final documents = querySnapshot.docs;
    if (documents.length > 0) {
      Invoice invoice = Invoice.fromJson(documents.first.data(),
          id: documents.first.id);
      if ((invoice.consecutive??0) > 0) {
        return invoice.consecutive??0;
      } else {
        return 0;
      }
    }
    return 0;
  }

  /// Get invoices images
  Future<List<String>> getImagesByIdInvoice(String invoiceId) async {
    List<String> imageList = <String>[];
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.invoices)
        .doc(invoiceId)
        .collection(FirestoreCollections.invoiceFieldImages)
        .get();

    final documents = querySnapshot.docs;
    if (documents.length > 0) {
      documents.forEach((product) {
        String imageGet = product.data()['imageUrl'];
        imageList.add(imageGet);
      });
    }
    return imageList;
  }

  /// Get Invoice By Id Invoice
  Future<Invoice> getInvoiceByIdInvoice(String invoiceId) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.invoices)
        .doc(invoiceId)
        .get();

    return Invoice.fromJson(querySnapshot.data() as Map<String, dynamic>, id: querySnapshot.id);
  }

  /// Get List Invoices by Placa, se tiene con + 2 para que muestre todo el historial del vehículo, si llegado el requerimiento que sea menos tiempo se modifica este valor y el where
  Future<List<Invoice>> getListInvoicesByVehicle(String plate, String companyId) async {
    try {
      var date = DateTime.now();
      var newDate = DateTime(date.year, date.month + 2, date.day);
      List<Invoice> listInvoices = [];
      final querySnapshot = await this
          ._db
          .collection(FirestoreCollections.invoices)
          .where(FirestoreCollections.invoiceFieldCompanyId, isEqualTo: companyId)
          .where(FirestoreCollections.invoiceFieldPlaca, isEqualTo: plate)
          .where(FirestoreCollections.invoiceFieldCreationDate, isLessThanOrEqualTo: newDate)
          .get();

      final documents = querySnapshot.docs;
      if (documents.length > 0) {
        documents.forEach((invoice) {
          listInvoices.add(Invoice.fromJson(invoice.data(), id: invoice.id));
        });
      }
      return listInvoices;
    } catch (e) {
      print('Error consultando servicios: $e');
      return Future.value(null);
    }
  }

  Future<Configuration> getConfiguration(String companyId) async {
    List<Configuration> configList = <Configuration>[];
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.configuration)
        .get();

    final snapShot = querySnapshot.docs;
    snapShot.forEach((document) {
      Configuration config =
          Configuration.fromJson(document.data(), id: document.id);
      configList.add(config);
    });
    return configList[0];
  }

  //TODO metodo para agregar regiones yu municipios, eliminar despues de cargados
  Future<void> uploadRegions() async {
    final url = Uri.parse(
        'https://raw.githubusercontent.com/marcovega/colombia-json/master/colombia.min.json');
    final res = await http.get(url);
    final List<dynamic> data = json.decode(res.body);

    for (var dep in data) {
      final name = dep['departamento'] as String;
      final ciudades = List<String>.from(dep['ciudades']);
      final municipalities = ciudades.map((c) => {'name': c}).toList();

      await _db
          .collection('regions')
          .doc()
          .set({
        'name': name,
        'municipalities': municipalities,
        'country': 'Colombia',
      });
      print('✅ $name (${name}) agregado con ${municipalities.length} municipios.');
    }
  }

  //TODO metodos que actualiza la compania en todas las invoices en batch
  Future<QuerySnapshot> getAllInvoicesPerBatch(int batchSize, DocumentSnapshot? lastDocument) async {
    Query querySnapshot = await this
        ._db
        .collection(FirestoreCollections.invoices)
        .limit(batchSize);
    if (lastDocument != null) {
      querySnapshot = querySnapshot.startAfterDocument(lastDocument);
    }
    return querySnapshot.get();
  }

  Future<void> getBatchInvoices(List<QueryDocumentSnapshot> docs, String companyId) async {
    final WriteBatch batch = _db.batch();

    for(final doc in docs) {
      batch.update(doc.reference, {FirestoreCollections.invoiceFieldCompanyId: companyId});
    }
    return batch.commit();
  }

  ///Metodo para actualizar masivamente el companiId llamando una función en cloud functions enviando el companiId
  Future<int?> updateBatchInvoicesFunction() async {
    try {
      // Llamar a tu función
      final HttpsCallable callable = _functions.httpsCallable('updateCustomersCompanyId');

      // Pasar datos si es necesario
      final result = await callable.call({
        'companyId': 'gtixUTsEImKUuhdSCwKX',
        'collection': 'invoices'
      }).timeout(Duration(seconds: 540));

      final data = result.data as Map<String, dynamic>;

      if (data['success'] == true) {
        print('Total de registros analizados: ${data['totalProcessed']}');
        print('Total de registros actualizados: ${data['totalUpdated']}');
        print(data['message']);
        return data['totalUpdated'] as int;
      } else {
        throw Exception(data['error'] ?? 'Error desconocido');
      }
    } catch (e) {
      print('Error llamando la función: $e');
    }
  }

  //Metodo para obtener el conteo total de invoices e invoices faltantes por companyId desde una funcion en cloud functions
  Future<int?> getInvoicesCountFunction() async {
    try {
      // Llamar a tu función
      final HttpsCallable callable = _functions.httpsCallable('countDocumentsToUpdate');
      //final HttpsCallableResult result = await callable.call().timeout(Duration(seconds: 540));

      // Pasar datos si es necesario
      final result = await callable.call({
        'collection': 'customers'
      }).timeout(Duration(seconds: 540));

      final data = result.data as Map<String, dynamic>;

      if (data['success'] == true) {
        print('Total de registros analizados: ${data['totalDocuments']}');
        print('Total de registros por actualizar: ${data['documentsToUpdate']}');
        print(data['message']);
        return data['documentsToUpdate'] as int;
      } else {
        throw Exception(data['error'] ?? 'Error desconocido');
      }
    } catch (e) {
      print('Error llamando la función: $e');
    }
  }

  //Método para obtener el contador de todas las facturas que ya tienen compañia
  Future<int?> getInvoicesCountPerCompany() async {
    try {
      var totalCount = await _db
        .collection(FirestoreCollections.invoices)
        .where(FirestoreCollections.invoiceFieldCompanyId, isEqualTo: 'gtixUTsEImKUuhdSCwKX')
        .count()
        .get();
      return totalCount.count;
    } catch (e) {
      print('Error llamando la función: $e');
    }
  }
}
