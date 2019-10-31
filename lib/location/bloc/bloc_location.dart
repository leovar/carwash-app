
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

  Future<DocumentReference> getLocationReference(String locationId) async {
    return await _locationRepository.getLocationReference(locationId);
  }

  Stream<QuerySnapshot> locationsListStream = Firestore.instance.collection(FirestoreCollections.locations).snapshots();
  Stream<QuerySnapshot> get locationsStream => locationsListStream;

  List<Location> buildLocations(List<DocumentSnapshot> locationsListSnapshot) => _locationRepository.buildLocations(locationsListSnapshot);

  @override
  void dispose() {
  }

}