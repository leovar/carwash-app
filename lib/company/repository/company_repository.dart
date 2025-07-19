import 'package:car_wash_app/company/model/company.dart';
import 'package:car_wash_app/company/model/contact_user.dart';
import 'package:car_wash_app/company/model/region.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/firestore_collections.dart';

class CompanyRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<Company> getCompanyInformationById(String companyId) async {
    final querySnapshot = await this
        ._db
        .collection(FirestoreCollections.company)
        .doc(companyId)
        .get();

    if (querySnapshot.data() != null) {
      return Company.fromJson(querySnapshot.data() as Map<String, dynamic>,
          id: querySnapshot.id);
    }
    return new Company(
      active: false,
      city: '',
      companyCode: 0,
      companyName: '',
      contactName: '',
      contactUsers: [],
      country: '',
      creationDate: Timestamp.now(),
      endDate: Timestamp.now(),
      licenseMonths: 0,
      licenseType: '',
      licenseTypeCode:0,
      nit: '',
      phone: '',
      startDate: Timestamp.now(),
      region: '',
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRegionsListStream() {
    final querySnapshot =
        this._db.collection(FirestoreCollections.regions).snapshots();
    return querySnapshot;
  }

  Future<void> updateCompany(Company company) async {
    var jsonCompany = company.toJson();
    var mapContacts = [];
    company.contactUsers?.forEach((item) {
      var toJsonContact = ContactUser().toJson();
      mapContacts.add(toJsonContact);
    });
    jsonCompany['contactUsers'] = mapContacts;

    DocumentReference ref =
    _db.collection(FirestoreCollections.company).doc(company.Id);
    return await ref.set(jsonCompany, SetOptions(merge: true));
  }

  List<Region> buildRegions(List<DocumentSnapshot> regionsListSnapshot) {
    List<Region> regionsList = [];
    regionsListSnapshot.forEach((p) {
      var data = p.data();
      if (data != null) {
        Region reg = Region.fromJson(data as Map<String, dynamic>, id: p.id);
        regionsList.add(reg);
      }
    });
    regionsList
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return regionsList;
  }
}
