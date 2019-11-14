import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoices_list/model/invoice_list_model.dart';
import 'package:car_wash_app/invoices_list/ui/widgets/item_invoices_list.dart';
import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/vehicle/bloc/bloc_vehicle.dart';
import 'package:car_wash_app/vehicle/model/vehicle.dart';
import 'package:car_wash_app/widgets/firestore_collections.dart';
import 'package:car_wash_app/widgets/gradient_back.dart';
import 'package:car_wash_app/widgets/info_header_container.dart';
import 'package:car_wash_app/widgets/keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormInvoicesList extends StatefulWidget {

  final locationReference;

  FormInvoicesList({Key key, this.locationReference});

  @override
  State<StatefulWidget> createState() => _FormInvoicesList();
}

class _FormInvoicesList extends State<FormInvoicesList> {
  BlocInvoice _blocInvoice;
  List<Invoice> _listInvoices = <Invoice>[];
  List<InvoiceListModel> _listModel = <InvoiceListModel>[];

  @override
  void dispose() {
    _blocInvoice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _blocInvoice = BlocProvider.of(context);

    //this._getPreferences();

    return Stack(
      children: <Widget>[
        GradientBack(),
        _bodyContainer(),
      ],
    );
  }

  Widget _bodyContainer() {
    return Column(
      children: <Widget>[
        InfoHeaderContainer(
          image: 'assets/images/icon_facturas_blanco.png',
          textInfo: 'Facturas',
        ),
        Flexible(
          child: _containerList(),
        ),
      ],
    );
  }

  Widget _containerList() {
    return Container(
      margin: EdgeInsets.only(right: 17, left: 17, bottom: 17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.0),
      ),
      child: Container(
        padding: EdgeInsets.only(
          right: 15,
          left: 15,
          top: 15,
          bottom: 15,
        ),
        child: Column(
          children: <Widget>[
            Visibility(
              visible: false,
              child: Container(
                height: 55,
                child: Row(),
              ),
            ),
            _getInvoices(),
          ],
        ),
      ),
    );
  }

  Widget _getInvoices() {
    var date = DateTime(DateTime.now().year, DateTime.now().month, 1);
    return StreamBuilder(
      stream: _blocInvoice.invoicesListByMonthStream(widget.locationReference, date),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return Expanded(
              child: _listItems(snapshot),
            );
        }
      },
    );
  }

  Widget _listItems(AsyncSnapshot snapshot) {
    _listInvoices = _blocInvoice.buildInvoicesListByMonth(snapshot.data.documents);
    _listInvoices.sort((a, b) => b.consecutive.compareTo(a.consecutive));
    _listModel.clear();
    _listInvoices.forEach((invoice){
      _listModel.add(InvoiceListModel(
          id: invoice.id,
          consec: invoice.consecutive,
          totalPrice: invoice.totalPrice,
          placa: '',
      ));
    });

    return ListView.builder(
      itemCount: _listInvoices.length,
      scrollDirection: Axis.vertical,
      itemBuilder: (BuildContext context, int index) {
        return ItemInvoicesList(
          listInvoices: _listInvoices,
          listInvoicesModel: _listModel,
          index: index,
          updateDate: true,
        );
      },
    );
  }

  /// Functions

}
