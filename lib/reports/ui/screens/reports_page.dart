import 'package:car_wash_app/reports/ui/screens/customers_report.dart';
import 'package:car_wash_app/reports/ui/screens/earnings_report.dart';
import 'package:car_wash_app/reports/ui/screens/productivity_report.dart';
import 'package:car_wash_app/widgets/app_bar_widget_simple.dart';
import 'package:flutter/material.dart';

class ReportsPage extends StatefulWidget {
  final String companyId;

  ReportsPage({Key? key, required this.companyId});

  @override
  State<StatefulWidget> createState() => _ReportsPage();
}

class _ReportsPage extends State<ReportsPage> {

  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final _tabPages = <Widget> [
      ProductivityReport(companyId: widget.companyId,),
      EarningsReport(companyId: widget.companyId,),
      CustomersReport(companyId: widget.companyId,),
    ];

    final _tabItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(icon: Icon(Icons.supervisor_account), label: 'productividad'),
      BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'ganancias'),
      BottomNavigationBarItem(icon: Icon(Icons.contacts), label: 'clientes'),
    ];
    assert(_tabPages.length == _tabItems.length);
    final bottomNavBar = BottomNavigationBar(
      items: _tabItems,
      currentIndex: _currentTabIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (int index) {
        setState(() {
          _currentTabIndex = index;
        });
      },
    );

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 65),
        child: SimpleAppBarWidget(),
      ),
      body: _tabPages[_currentTabIndex],
      bottomNavigationBar: bottomNavBar,

    );
  }
}
