import 'package:car_wash_app/invoice/model/additional_product.dart';
import 'package:car_wash_app/invoice/model/header_services.dart';
import 'package:car_wash_app/invoice/ui/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/dart2js.dart';

class AdditionalProductPage extends StatefulWidget {
  final Function(List<AdditionalProduct>) setCbAdditionalProducts;
  final List<AdditionalProduct> additionalProductsList;
  final HeaderServices vehicleTypeSelect;
  final bool editForm;

  AdditionalProductPage(
      {Key key, this.setCbAdditionalProducts, this.additionalProductsList, this.editForm, this.vehicleTypeSelect,});

  @override
  State<StatefulWidget> createState() {
    return _AdditionalProductPage();
  }
}

class _AdditionalProductPage extends State<AdditionalProductPage> {
  final _textAdditionalService = TextEditingController();
  final _valueAdditionalService = TextEditingController();
  final _valueServiceTime = TextEditingController();
  bool _checkIva = false;
  FocusNode nameFocusNode;

  @override
  void initState() {
    super.initState();
    nameFocusNode = FocusNode();
  }

  @override
  void dispose() {
    nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Servicios Adicionales",
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
      body: _moreServices(),
    );
  }

  Widget _moreServices() {
    return Container(
      color: Colors.grey,
      child: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    TextFieldInput(
                      labelText: "Servicio Adicional",
                      textController: _textAdditionalService,
                      focusNode: nameFocusNode,
                    ),
                    SizedBox(
                      height: 9,
                    ),
                    TextFieldInput(
                      labelText: "Valor",
                      textController: _valueAdditionalService,
                      inputType: TextInputType.numberWithOptions(decimal: true, signed: true),
                      textInputFormatter: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9\.]')),
                      ],
                    ),
                    SizedBox(
                      height: 9,
                    ),
                    TextFieldInput(
                      labelText: "Tiempo del servicio en minutos",
                      textController: _valueServiceTime,
                      inputType: TextInputType.numberWithOptions(decimal: true, signed: true),
                      textInputFormatter: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                      ],
                    ),
                    SizedBox(
                      height: 9,
                    ),
                    Row(
                      children: <Widget>[
                        Checkbox(
                          value: _checkIva,
                          onChanged: (bool value) {
                            if (mounted) {
                              setState(() {
                                _checkIva = value;
                              });
                            }
                          },
                          checkColor: Colors.white,
                          activeColor: Color(0xFF59B258),
                        ),
                        Text(
                          "Aplica para Iva",
                          style: TextStyle(
                            fontFamily: "Lato",
                            decoration: TextDecoration.none,
                            color: Color(0xFFAEAEAE),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      child: Align(
                        alignment: Alignment.center,
                        child: RaisedButton(
                          padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          color: Color(0xFF59B258),
                          child: Text(
                            "Agregar Servicio",
                            style: TextStyle(
                              fontFamily: "Lato",
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: widget.editForm ? () {
                            _addAdditionalProduct();
                          } : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Flexible(
            child: Card(
              color: Colors.white,
              elevation: 15,
              margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.additionalProductsList.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (BuildContext context, int index) {
                    return _itemDecorationAddProduct(index);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemDecorationAddProduct(int index) {
    AdditionalProduct addProduct = widget.additionalProductsList[index];
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 50,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFD8D8D8),
              width: 1.0,
            ),
          ),
        ),
        child: Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10),
              width: 45,
              child: IconButton(
                icon: Icon(Icons.cancel),
                color: Colors.red,
                iconSize: 26,
                onPressed: widget.editForm ? () {
                  _deleteItemAdditionalProduct(index);
                } : null,
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(left: 6),
                child: Text(
                  addProduct.productName + " - \$" + addProduct.productValue,
                  style: TextStyle(
                    fontFamily: "Lato",
                    decoration: TextDecoration.none,
                    color: Color(0xFFAEAEAE),
                    fontSize: 17,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _deleteItemAdditionalProduct(index) {
    if (mounted) {
      setState(() {
        widget.additionalProductsList.removeAt(index);
        widget.setCbAdditionalProducts(widget.additionalProductsList);
        FocusScope.of(context).requestFocus(nameFocusNode);
      });
    }
  }

  void _addAdditionalProduct() {
    String productType = 'Sencillo';
    int serviceTime = int.tryParse(_valueServiceTime.text) == null ? 0 : int.parse(_valueServiceTime.text);
    double _iva = 0;
    if(_checkIva) {
      _iva = 19;
    }
    
    if (widget.vehicleTypeSelect.uid.toString().contains('1') || widget.vehicleTypeSelect.uid.toString().contains('2')) {
      productType = 'Especial';
    }

    AdditionalProduct product = AdditionalProduct(
      _textAdditionalService.text,
      _valueAdditionalService.text,
      _iva,
      true,
      productType,
      serviceTime,
    );

    _checkIva = false;
    _valueAdditionalService.text = '';
    _textAdditionalService.text = '';
    _valueServiceTime.text = '';

    if (mounted) {
      setState(() {
        widget.additionalProductsList.add(product);
        widget.setCbAdditionalProducts(widget.additionalProductsList);
        FocusScope.of(context).requestFocus(nameFocusNode);
      });
    }
  }
}
