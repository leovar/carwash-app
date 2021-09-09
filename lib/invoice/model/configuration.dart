import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

@immutable
class Configuration extends Equatable {
  final String id;
  final String emailFrom;
  final String passFrom;
  final String smtpFrom;

  Configuration({
    this.id,
    this.emailFrom,
    this.passFrom,
    this.smtpFrom,
  });

  factory Configuration.fromJson(Map<String, dynamic> json, {String id}) {
    return Configuration(
      id: id,
      emailFrom: json['emailFrom'],
      passFrom: json['passFrom'],
      smtpFrom: json['smtpFrom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emailFrom': this.emailFrom,
      'passFrom': this.passFrom,
      'smtpFrom': this.smtpFrom,
    };
  }

  @override
  List<Object> get props => [
    id,
    emailFrom,
    passFrom,
    smtpFrom,
  ];
}