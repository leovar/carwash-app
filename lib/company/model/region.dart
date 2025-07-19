import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'municipality.dart';

@immutable
class Region extends Equatable {
  final String Id;
  final String country;
  final List<Municipality> municipalities;
  final String name;

  Region({
    required this.Id,
    required this.country,
    required this.municipalities,
    required this.name
  });

  factory Region.fromJson(Map<String, dynamic> json, {required String id}) {
    List<Municipality> municipalityListDb = <Municipality>[];
    var municipalitiesList = json['municipalities']??[];
    municipalitiesList?.forEach((item) {
      Municipality cu = Municipality.fromJson(item);
      municipalityListDb.add(cu);
    });

    return Region(
      Id: id,
      country: json['country'],
      municipalities: municipalityListDb,
      name: json['name'],
    );
  }

  @override
  List<Object?> get props => [
    Id,
    country,
    municipalities,
    name,
  ];
}
