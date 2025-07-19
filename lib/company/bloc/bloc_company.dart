import 'package:car_wash_app/company/model/company.dart';
import 'package:car_wash_app/company/model/region.dart';
import 'package:car_wash_app/company/repository/company_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class BlocCompany implements Bloc {
  final _companyRepository = CompanyRepository();

  Future<Company> getCompanyInformation(String idCompany) async {
    return await _companyRepository.getCompanyInformationById(idCompany);
  }

  Future<void> updateCompanyInformation(Company company) async {
    await _companyRepository.updateCompany(company);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> regionsStream() {
    return _companyRepository.getRegionsListStream();
  }

  List<Region> buildRegions(List<DocumentSnapshot> regionsListSnapshot) =>
      _companyRepository.buildRegions(regionsListSnapshot);

  @override
  void dispose() {}
}
