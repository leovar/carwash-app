import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/cells_model.dart';
import 'package:car_wash_app/invoice/model/configuration.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/model/queue_model.dart';
import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/turns/ui/widgets/change_active_cells_widget.dart';
import 'package:car_wash_app/turns/ui/widgets/item_waiting_list.dart';
import 'package:car_wash_app/turns/ui/widgets/item_washing_list.dart';
import 'package:car_wash_app/turns/ui/widgets/select_turn_cell_widget.dart';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/widgets/gradient_back.dart';
import 'package:car_wash_app/widgets/keys.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class FormTurns extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _FormTurns();
}

class _FormTurns extends State<FormTurns> with SingleTickerProviderStateMixin {
  BlocInvoice _blocInvoice;
  final _locationBloc = BlocLocation();
  UserBloc _blocUser = UserBloc();

  var _estimatedWaitingTime = Duration(minutes: 0);
  List<Invoice> _listInvoicesWaiting = <Invoice>[];
  List<Invoice> _listInvoicesWashing = <Invoice>[];
  String _locationName;
  String _idLocation;
  DocumentReference _locationReference;
  Location _locationData = new Location();
  CellsModel _cellSelected = CellsModel('', '');
  int _activeCellsSelected = 0;
  User _currentUser;
  TabController _tabController;
  final _textWorkers = TextEditingController();

  Configuration _config = Configuration();
  Timer _everyMinute;

  @override
  void initState() {
    super.initState();
    _blocUser.getCurrentUser().then((User user) {
      _currentUser = user;
    });
    _tabController = new TabController(length: 2, vsync: this);
    this._getPreferences();
    _everyMinute = Timer.periodic(Duration(minutes: 1), (Timer t) {
      setState(() {});
    });
    _getInitLists();
  }

  @override
  void dispose() {
    super.dispose();
    _blocInvoice.dispose();
    _locationBloc.dispose();
    _tabController.dispose();
    _everyMinute.cancel();
  }

  @override
  Widget build(BuildContext context) {
    this._blocInvoice = BlocProvider.of<BlocInvoice>(context);
    _countEstimateWashTime();
    return Column(
      children: <Widget>[
        _headerTurns(),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: _bodyContainer(),
          ),
        ),
      ],
    );
  }

  Widget _headerTurns() {
    return Container(
      height: 125,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFD8D8D8),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Flexible(
                          child: Text(
                            'Tiempo de espera estimado',
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontFamily: "Lato",
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 10),
                        Flexible(
                          child: Text(
                            _printDuration(_estimatedWaitingTime),
                            style: TextStyle(
                              fontFamily: "Lato",
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                  color: Colors.grey,
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Text(
                          'Vehículos en lavado',
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontFamily: "Lato",
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10),
                        Text(
                          _listInvoicesWashing.length.toString(),
                          style: TextStyle(
                            fontFamily: "Lato",
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                  color: Colors.grey,
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Flexible(
                          child: Text(
                            'Vehículos en espera',
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                              fontFamily: "Lato",
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(height: 10),
                        Flexible(
                          child: Text(
                            _listInvoicesWaiting.length.toString(),
                            style: TextStyle(
                              fontFamily: "Lato",
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 30,
            padding: EdgeInsets.only(left: 10, right: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //mainAxisSize: MainAxisSize.max,
              children: [
                Text(
                  'Celdas activas:   ' + _locationData.activeCells.toString(),
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontFamily: "Lato",
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                InkWell(
                  onTap: _changeActiveCellsValue,
                  child: Image.asset(
                    'assets/images/icon_filter1.png',
                    width: 23.0,
                    height: 23.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _bodyContainer() {
    return <Widget>[
      Material(
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          unselectedLabelColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).accentColor,
          tabs: [
            Tab(
              text: 'En Lavado',
            ),
            Tab(
              text: 'En Espera',
            ),
          ],
        ),
      ),
      Expanded(
        child: TabBarView(
          children: [
            _washingList(),
            _waitingList(),
          ],
          controller: _tabController,
        ),
      ),
    ];
  }

  Widget _waitingList() {
    return StreamBuilder(
      stream: _blocInvoice.invoicesListPendingWashingStream(this._locationReference),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return _containerWaitingList(snapshot);
      },
    );
  }

  Widget _containerWaitingList(AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        _listInvoicesWaiting = [];
        break;
      default:
        _listInvoicesWaiting = _blocInvoice
            .buildInvoicesListPendingWashing(snapshot.data.documents);
        _listInvoicesWaiting
            .sort((b, a) => b.consecutive.compareTo(a.consecutive));
        _countEstimateWashTime();

    }

    return Container(
      padding: EdgeInsets.only(
        bottom: 15,
      ),
      child: ListView.builder(
        itemCount: _listInvoicesWaiting.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return ItemWaitingList(
            listInvoices: _listInvoicesWaiting,
            index: index,
            assignTurn: _assignTurnCallback,
          );
        },
      ),
    );
  }

  Widget _washingList() {
    return StreamBuilder(
      stream: _blocInvoice.invoicesListWashingStream(this._locationReference),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        return _containerWashingList(snapshot);
      },
    );
  }

  Widget _containerWashingList(AsyncSnapshot snapshot) {
    switch (snapshot.connectionState) {
      case ConnectionState.waiting:
        _listInvoicesWashing = [];
        break;
      default:
        _listInvoicesWashing =
            _blocInvoice.buildInvoicesListWashing(snapshot.data.documents);
        _listInvoicesWashing
            .sort((a, b) => b.consecutive.compareTo(a.consecutive));
        _countEstimateWashTime();
    }

    return Container(
      padding: EdgeInsets.only(
        bottom: 15,
      ),
      child: ListView.builder(
        itemCount: _listInvoicesWashing.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          return ItemWashingList(
            listInvoices: _listInvoicesWashing,
            index: index,
            endWash: _endWashCallback,
          );
        },
      ),
    );
  }

  void _getPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    _locationName = pref.getString(Keys.locationName);
    if (_idLocation?.isEmpty ?? true) {
      _idLocation = pref.getString(Keys.idLocation);
      _locationBloc.getLocationReference(_idLocation).then((value) {
        setState(() {
          _locationReference = value;
        });
        _getInitLists();
      });
      _locationBloc
          .getLocationById(_idLocation)
          .then((loc) => _locationData = loc);
    }
    //_blocInvoice.getConfigurationObject().then((value) => _config = value);
  }

  void _assignTurnCallback(Invoice _invoiceClose) {
    _cellSelected = (_invoiceClose.washingCell?.isEmpty ?? true)
        ? new CellsModel('', '')
        : CellsModel(_invoiceClose.washingCell, _invoiceClose.washingCell);
    Alert(
      context: context,
      title: 'Seleccione la celda de lavado',
      style: MessagesUtils.alertStyle,
      content: SelectTurnCellWidget(
        selectCell: _callBackSelectCell,
        workersController: _textWorkers,
        cellSelected: _cellSelected,
        locationData: _locationData,
        listCurrentWashing: _listInvoicesWashing,
      ),
      buttons: [
        DialogButton(
          color: Theme.of(context).accentColor,
          child: Text(
            'ASIGNAR',
            style: Theme.of(context).textTheme.button,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            _completeAssignCell(_invoiceClose);
          },
        )
      ],
    ).show();
  }

  void _callBackSelectCell(CellsModel cellSelected) {
    _cellSelected = cellSelected;
  }

  void _completeAssignCell(Invoice invoiceToSave) async {
    if (_cellSelected.text.isNotEmpty) {
      Invoice invoice = Invoice.copyWith(
        origin: invoiceToSave,
        startWashing: true,
        washingCell: _cellSelected.value,
        dateStartWashing: Timestamp.now(),
        countWashingWorkers: int.parse(_textWorkers?.text ?? '1'),
      );
      await _blocInvoice.saveInvoice(invoice);
      _textWorkers.text = '';
    }
  }

  void _endWashCallback(Invoice _invoiceToEnd) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: 'Esta seguro que desea terminar el lavado !',
      style: MessagesUtils.alertWarningStyle,
      buttons: [
        DialogButton(
          color: Theme.of(context).accentColor,
          child: Text(
            'ACEPTAR',
            style: Theme.of(context).textTheme.button,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            _endInvoiceWash(_invoiceToEnd);
          },
        ),
        DialogButton(
          color: Theme.of(context).accentColor,
          child: Text(
            'CANCELAR',
            style: Theme.of(context).textTheme.button,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            setState(() {});
          },
        ),
      ],
    ).show();
  }

  void _endInvoiceWash(Invoice _invoiceToEnd) async {
    bool endWashValue = false;
    Timestamp endWashData;
    int washingTimeValue;
    if (_invoiceToEnd.startWashing && !_invoiceToEnd?.endWash ?? false) {
      DateTime dateStart = _invoiceToEnd.dateStartWashing.toDate();
      DateTime dateCurrent = DateTime.now();
      Duration diff = dateCurrent.difference(dateStart);
      int washCurrentDuration = diff.inMinutes;
      washingTimeValue = washCurrentDuration;
      endWashValue = true;
      endWashData = Timestamp.now();

      Invoice invoice = Invoice.copyWith(
        origin: _invoiceToEnd,
        endWash: endWashValue,
        dateEndWash: endWashData,
        washingTime: washingTimeValue,
      );
      _blocInvoice.saveInvoice(invoice).then((value) => _countEstimateWashTime());
    }
  }

  void _countEstimateWashTime () {
    List<QueueModel> _queueActiveCellsList = List<QueueModel>();
    List<QueueModel> _queueWashingCellsList = List<QueueModel>();
    if (_locationData.activeCells != null && _locationData.activeCells > 0) {
      if (_listInvoicesWashing.length > 0) {
        _listInvoicesWashing.forEach((item) {
          DateTime dateStartWash = item.dateStartWashing.toDate();
          DateTime dateCurrent = DateTime.now();
          Duration diff = dateCurrent.difference(dateStartWash);
          int washCurrentDuration = diff.inMinutes;
          int invoiceDuration = item.washingServicesTime == null
              ? 0
              : item.washingServicesTime;
          if (item.countWashingWorkers > 1) {
            invoiceDuration = (invoiceDuration / item.countWashingWorkers).round();
          }
          int remainingDuration = invoiceDuration - washCurrentDuration;
          if (_queueWashingCellsList.where((e) => e.cell == item.washingCell).length == 0) {
            QueueModel newItem = new QueueModel(item.washingCell, remainingDuration);
            _queueWashingCellsList.add(newItem);
          } else {
            QueueModel queueTime = _queueWashingCellsList.firstWhere((e) => e.cell == item.washingCell);
            queueTime.time = queueTime.time + (remainingDuration < 0 ? 0 : remainingDuration);
          }
        });
      }

      for (int i= 0; i < _locationData.activeCells; i++) {
        _queueActiveCellsList.add(QueueModel((i+1).toString(), 0));
      }

      if (_queueWashingCellsList.length > _queueActiveCellsList.length) {
        _queueWashingCellsList.sort((a, b) => a.time.compareTo(b.time));
        for(var i=0; i<_queueActiveCellsList.length; i++) {
          _queueActiveCellsList[i].time = _queueWashingCellsList[i].time;
        }
      } else {
        _queueActiveCellsList.forEach((element) {
          if (_queueWashingCellsList.where((e) => e.cell == element.cell).length > 0) {
            QueueModel queueWashingTime = _queueWashingCellsList.firstWhere((e) => e.cell == element.cell);
            QueueModel queueActiveTime = _queueActiveCellsList.firstWhere((e) => e.cell == element.cell);
            queueActiveTime.time = queueWashingTime.time;
          }
        });
      }

      if (_listInvoicesWaiting.length > 0) {
        _listInvoicesWaiting.sort((a, b) => a.washingServicesTime.compareTo(b.washingServicesTime));
        _listInvoicesWaiting.forEach((item) {
          var min = _queueActiveCellsList.first;
          _queueActiveCellsList.forEach((e) {
            if(e.time < min.time) min = e;
          });

          QueueModel queueTime = _queueActiveCellsList.firstWhere((e) => e.cell == min.cell);
          queueTime.time = queueTime.time + (item.washingServicesTime == null ? 0 : item.washingServicesTime);
        });
      }
      var minTime = _queueActiveCellsList.first;
      _queueActiveCellsList.forEach((e) {
        if(e.time < minTime.time) minTime = e;
      });
      _estimatedWaitingTime = Duration(minutes: minTime.time < 0 ? 0 : minTime.time);
    } else {
      _estimatedWaitingTime = Duration(minutes: 0);
    }
  }

  void _getInitLists () async {
    if (this._locationReference != null) {
      List<Invoice> pendingWash = <Invoice>[];
      _blocInvoice.getListPendingWashList(this._locationReference).then((value) {
        pendingWash = value;
        _blocInvoice.invoicesWashingList(this._locationReference).then((items) {
          setState(() {
            _listInvoicesWaiting = pendingWash;
            _listInvoicesWashing = items;
          });
        });
      });
    }
  }

  void _changeActiveCellsValue() {
    Alert(
      context: context,
      title: 'Seleccione las celdas activas',
      style: MessagesUtils.alertStyle,
      content: ChangeActiveCellsWidget(
        selectActiveCells: _callBackSelectActiveCells,
        locationData: _locationData,
      ),
      buttons: [
        DialogButton(
          color: Theme.of(context).accentColor,
          child: Text(
            'ASIGNAR',
            style: Theme.of(context).textTheme.button,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            _completeAssignActiveCells();
          },
        )
      ],
    ).show();
  }

  void _callBackSelectActiveCells(int cellsSelected) {
    _activeCellsSelected = cellsSelected;
  }

  void _completeAssignActiveCells() async {
    if (_activeCellsSelected != null) {
      Location location = Location.copyWith(
          origin: _locationData,
          activeCells: _activeCellsSelected,
      );
      await _locationBloc.updateLocationData(location);
      _locationBloc
          .getLocationById(_idLocation)
          .then((loc) {
          setState(() {
            _locationData = loc;
          });
      });
      _activeCellsSelected = 0;
    }
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
