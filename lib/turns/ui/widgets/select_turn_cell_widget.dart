import 'package:car_wash_app/invoice/model/cells_model.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectTurnCellWidget extends StatefulWidget {
  final Function(CellsModel) selectCell;
  final TextEditingController workersController;
  final CellsModel cellSelected;
  final Location locationData;
  final List<Invoice> listCurrentWashing;

  SelectTurnCellWidget({
    Key? key,
    required this.selectCell,
    required this.workersController,
    required this.cellSelected,
    required this.locationData,
    required this.listCurrentWashing,
  });

  @override
  State<StatefulWidget> createState() => _SelectTurnCellWidget();
}

class _SelectTurnCellWidget extends State<SelectTurnCellWidget> {
  List<DropdownMenuItem<CellsModel>>? _dropdownMenuItems;
  CellsModel _selectedCell = new CellsModel('', '');

  @override
  void initState() {
    super.initState();
    if (widget.cellSelected.value != '') {
      _selectedCell = widget.cellSelected;
    }
    widget.workersController.text = '1';
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[_getCellsList(), SizedBox(height: 12)]);
  }

  Widget _getCellsList() {
    List<CellsModel> listCells = getCellsList(widget.locationData.activeCells??0);
    widget.listCurrentWashing.forEach((item) {
      var cell = item.washingCell;
      listCells.removeWhere((item) => item.value == cell);
    });
    if (_selectedCell.value.isEmpty) {
      listCells.add(_selectedCell);
    }

    if (_dropdownMenuItems == null) {
      _dropdownMenuItems = builtDropdownMenuItems(listCells);
    }

    return Column(
      children: [
        DropdownButton(
          isExpanded: true,
          items: _dropdownMenuItems,
          value: _selectedCell,
          onChanged: onChangeDropDawnCell,
          hint: Text("Seleccione una celda de lavado..."),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: Theme.of(context).cardColor,
          ),
          iconSize: 24,
          elevation: 16,
          style: TextStyle(
            fontFamily: "AvenirNext",
            fontWeight: FontWeight.normal,
            color: Theme.of(context).cardColor,
          ),
          underline: Container(height: 1, color: Theme.of(context).textSelectionTheme.cursorColor),
        ),
        TextField(
          controller: widget.workersController,
          decoration: InputDecoration(labelText: '# De operarios en celda'),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        Visibility(
          visible: listCells.length == 0,
          child: Text(
            'No hay celdas disponible para asignar',
            style: TextStyle(fontFamily: "Lato", fontSize: 22),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<CellsModel>> builtDropdownMenuItems(
    List<CellsModel> listCellItems,
  ) {
    List<DropdownMenuItem<CellsModel>> listItems = [];
    for (CellsModel cellItem in listCellItems) {
      listItems.add(
        DropdownMenuItem(value: cellItem, child: Text(cellItem.text)),
      );
    }
    return listItems;
  }

  List<CellsModel> getCellsList(int cellsData) {
    List<CellsModel> listCellItems = [];
    for (int i = 0; i < cellsData; i++) {
      listCellItems.add(CellsModel((i + 1).toString(), (i + 1).toString()));
    }
    return listCellItems;
  }

  onChangeDropDawnCell(CellsModel? selectedCell) {
    widget.selectCell(selectedCell?? new CellsModel('', ''));
    setState(() {
      _selectedCell = selectedCell ?? new CellsModel('', '');
    });
  }
}
