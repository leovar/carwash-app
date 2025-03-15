
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:meta/meta.dart';

@immutable
class Configuration extends Equatable {
  final String id;
  final String emailFrom;
  final String passFrom;
  final String smtpFrom;
  final double salaryMonth;
  final double salaryDay;

  Configuration({
    this.id,
    this.emailFrom,
    this.passFrom,
    this.smtpFrom,
    this.salaryMonth,
    this.salaryDay,
  });

  factory Configuration.fromJson(Map<String, dynamic> json, {String id}) {
    return Configuration(
      id: id,
      emailFrom: json['emailFrom'],
      passFrom: json['passFrom'],
      smtpFrom: json['smtpFrom'],
      salaryMonth: json['salaryMonth'].toDouble(),
      salaryDay: json['salaryDay'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emailFrom': this.emailFrom,
      'passFrom': this.passFrom,
      'smtpFrom': this.smtpFrom,
      'salaryMonth': this.salaryMonth,
      'salaryDay': this.salaryDay,
    };
  }

  @override
  List<Object> get props => [
    id,
    emailFrom,
    passFrom,
    smtpFrom,
    salaryMonth,
    salaryDay,
  ];
}