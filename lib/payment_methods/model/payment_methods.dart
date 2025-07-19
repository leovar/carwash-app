import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

@immutable
class PaymentMethod extends Equatable {
  final String? id;
  final String? name;
  final bool? active;
  final String companyId;

  PaymentMethod({
    this.id,
    this.name,
    this.active,
    required this.companyId,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json, {String? id}) {
    return PaymentMethod(
      id: id,
      name: json['name'],
      active: json['active'],
      companyId: json['companyId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'active': this.active,
      'companyId': this.companyId,
    };
  }

  @override
  List<Object> get props => [
    id ?? '',
    name ?? '',
    active ?? true,
    companyId ?? '',
  ];
}
