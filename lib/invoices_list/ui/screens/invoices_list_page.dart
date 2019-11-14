import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoices_list/ui/widgets/form_invoices_list.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/widgets/app_bar_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class InvoicesListPage extends StatefulWidget {

  final user;
  final locationReference;

  InvoicesListPage({Key key, this.user, this.locationReference});

  @override
  State<StatefulWidget> createState() => _InvoicesListPage();
}

class _InvoicesListPage extends State<InvoicesListPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 65),
        child: AppBarWidget(_scaffoldKey, widget.user.photoUrl, false),
      ),
      body: BlocProvider<BlocInvoice>(
        bloc: BlocInvoice(),
        child: SafeArea(
          child: FormInvoicesList(locationReference: widget.locationReference,),
        ),
      ),
    );
  }
}