import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/location/repository/location_repository.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class BlocLocation implements Bloc {
  final _locationRepository = LocationRepository();

  //Casos de uso del objeto User
  //1. Obtener locaciones desde la bd
  //2. Crear o Editar locaciones

  Future<DocumentReference> updateLocationData(Location location) async {
    DocumentReference ref =
        await _locationRepository.updateLocationDataRepository(location);
    return ref;
  }

  Future<DocumentReference> getLocationReference(String locationId) async {
    return await _locationRepository.getLocationReference(locationId);
  }

  Future<Location> getLocationById(String locationId) async {
    return await _locationRepository.getLocationById(locationId);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> locationsListStream(
      String companyId) {
    return _locationRepository.getLocationsListStream(companyId);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> locationsStream(String companyId) =>
      locationsListStream(companyId);

  List<Location> buildLocations(List<DocumentSnapshot> locationsListSnapshot) =>
      _locationRepository.buildLocations(locationsListSnapshot);

  Future<List<Location>> getLocationsList(String companyId) => _locationRepository.getLocations(companyId);

  DocumentReference getDocumentReferenceLocationById(String idLocation) =>
      _locationRepository.getDocumentReferenceLocationById(idLocation);

  Stream<QuerySnapshot> allLocationsStream(String companyId) =>
      _locationRepository.getAllLocationsStream(companyId);

  @override
  void dispose() {}
}
