import 'package:car_wash_app/commission/bloc/bloc_commission.dart';
import 'package:car_wash_app/commission/model/commission.dart';
import 'package:car_wash_app/commission/ui/widgets/item_commission_admin_list.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';

class CommissionListAdminPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CommissionListAdminPage();
}

class _CommissionListAdminPage extends State<CommissionListAdminPage> {
  BlocCommission _blocCommission;
  List<Commission> _commissionList = <Commission>[];

  @override
  Widget build(BuildContext context) {
    _blocCommission = BlocProvider.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Comisiones",
          style: TextStyle(
            fontFamily: "Lato",
            decoration: TextDecoration.none,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: _containerBody(),
      ),
    );
  }

  Widget _containerBody() {
    return Container(
      padding: EdgeInsets.only(bottom: 5),
      color: Colors.white,
      child: StreamBuilder(
        stream: _blocCommission.allCommissionStream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return CircularProgressIndicator();
            default:
              return _getDataListCommissions(snapshot);
          }
        },
      ),
    );
  }

  Widget _getDataListCommissions(AsyncSnapshot snapshot) {
    _commissionList = _blocCommission.buildAllCommissions(snapshot.data.documents);
    _commissionList.sort((a,b)=> a.uidVehicleType.compareTo(b.uidVehicleType));

    return ListView.builder(
      itemCount: _commissionList.length,
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return ItemCommissionAdminList(_commissionList, index);
      },
    );
  }
}
