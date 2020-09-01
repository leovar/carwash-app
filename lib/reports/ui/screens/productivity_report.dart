import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProductivityReport extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProductivityReport();
}

class _ProductivityReport extends State<ProductivityReport> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Productividad'),
    );
  }
}
