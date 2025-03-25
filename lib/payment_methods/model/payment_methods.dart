import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

@immutable
class PaymentMethod extends Equatable {
  final String? id;
  final String? name;
  final bool? active;

  PaymentMethod({
    this.id,
    this.name,
    this.active,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json, {String? id}) {
    return PaymentMethod(
      id: id,
      name: json['name'],
      active: json['active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'active': this.active,
    };
  }

  @override
  List<Object> get props => [
    id!,
    name!,
    active!,
  ];
}
