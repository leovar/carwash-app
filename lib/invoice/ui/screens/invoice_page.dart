
import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/ui/widgets/form_invoice.dart';
import 'package:car_wash_app/widgets/app_bar_widget.dart';
import 'package:car_wash_app/widgets/drawer_page.dart';
import 'package:car_wash_app/widgets/keys.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvoicePage extends StatefulWidget {
  final bool? showDrawer;
  final Invoice? invoiceToEdit;

  InvoicePage({Key? key, this.showDrawer, this.invoiceToEdit});

  @override
  State<StatefulWidget> createState() {
    return _InvoicePage();
  }
}

class _InvoicePage extends State<InvoicePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  String photoUser = '';

  @override
  void initState() {
    super.initState();
    _getPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 65),
        child: AppBarWidget(_scaffoldKey, photoUser, false),
      ),
      body: BlocProvider<BlocInvoice>(
        bloc: BlocInvoice(),
        child: SafeArea(
          child: FormInvoice(
            widget.invoiceToEdit,
          ),
        ),
      ),
      drawer: (widget.showDrawer??false) ? DrawerPage() : null,
    );
  }

  void _getPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String userId = pref.getString(Keys.userId)??'';
    setState(() {
      photoUser = pref.getString(Keys.photoUserUrl)??'';
    });
  }
}
