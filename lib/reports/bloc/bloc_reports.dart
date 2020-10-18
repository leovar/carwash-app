
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/reports/repository/reports_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class BlocReports implements Bloc {
  final _reportsRepository = ReportsRepository();

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

  @override
  void dispose() {
  }

}