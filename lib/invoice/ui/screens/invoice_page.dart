import 'package:car_wash_app/User/model/user.dart';
import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/ui/widgets/form_invoice.dart';
import 'package:car_wash_app/widgets/app_bar_widget.dart';
import 'package:car_wash_app/widgets/drawer_page.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class InvoicePage extends StatefulWidget {
  final User usuario;
  bool showDrawer = true;

  InvoicePage({Key key, @required this.usuario, this.showDrawer});

  @override
  State<StatefulWidget> createState() {
    return _InvoicePage();
  }
}

class _InvoicePage extends State<InvoicePage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 65),
        child: AppBarWidget(_scaffoldKey, widget.usuario, false),
      ),
      body: BlocProvider<BlocInvoice>(
        bloc: BlocInvoice(),
        child: SafeArea(
          child: FormInvoice(),
        ),
      ),
      drawer: widget.showDrawer ? DrawerPage(widget.usuario) : null,
    );
  }
}
