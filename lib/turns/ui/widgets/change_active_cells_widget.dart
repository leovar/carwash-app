import 'package:car_wash_app/invoice/model/cells_model.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:flutter/material.dart';

class ChangeActiveCellsWidget extends StatefulWidget {
  final Function(int) selectActiveCells;
  final Location locationData;

  ChangeActiveCellsWidget({Key? key, required this.selectActiveCells, required this.locationData});

  @override
  State<StatefulWidget> createState() => _ChangeActiveCellsWidget();
}

class _ChangeActiveCellsWidget extends State<ChangeActiveCellsWidget> {
  List<DropdownMenuItem<CellsModel>> _dropdownMenuItems = [];
  CellsModel _selectedActiveCells = new CellsModel('', '');

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      _getCellsList(),
      SizedBox(height: 12),
    ]);
  }

  Widget _getCellsList() {
    List<CellsModel> listCells = getCellsList(widget.locationData.totalCells??0);
    if (_dropdownMenuItems.isEmpty) {
      _dropdownMenuItems = builtDropdownMenuItems(listCells);
    }
    return Column(
      children: [
        DropdownButton(
          isExpanded: true,
          items: _dropdownMenuItems,
          value: _selectedActiveCells,
          onChanged: onChangeDropDawnCell,
          hint: Text("Seleccione el número de celdas..."),
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
    if (_selectedActiveCells.value == '') {
      listItems.add(
        DropdownMenuItem(value: _selectedActiveCells, child: Text(_selectedActiveCells.text)),
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

  onChangeDropDawnCell(CellsModel? selectedCells) {
    setState(() {
      widget.selectActiveCells(int.parse(selectedCells?.value??'0'));
      _selectedActiveCells = selectedCells?? new CellsModel('', '');
    });
  }
}
