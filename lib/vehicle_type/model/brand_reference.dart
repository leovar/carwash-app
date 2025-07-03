import 'package:equatable/equatable.dart';

class BrandReference extends Equatable {
  final String? id;
  final String? reference;
  final bool? active;

  BrandReference({
    this.id,
    this.reference,
    this.active,
  });

  factory BrandReference.fromJson(Map<String, dynamic> json, {required String id}) {
    return BrandReference(
      id: id,
      reference: json['reference'],
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reference': this.reference,
      'active': this.active,
    };
  }

  @override
  List<Object> get props => [
    id!,
    reference!,
    active!,
  ];
}
