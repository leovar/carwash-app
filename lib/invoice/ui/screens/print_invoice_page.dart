import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:car_wash_app/customer/bloc/bloc_customer.dart';
import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/invoice/model/additional_product.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/widgets/keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as im;
import 'package:shared_preferences/shared_preferences.dart';

class PrintInvoicePage extends StatefulWidget {
  final Invoice currentInvoice;
  final List<Product> selectedProducts;
  final List<AdditionalProduct> additionalProducts;

  PrintInvoicePage(
      {Key key,
      this.currentInvoice,
      this.selectedProducts,
      this.additionalProducts});

  @override
  State<StatefulWidget> createState() => _PrintInvoicePage();
}

class _PrintInvoicePage extends State<PrintInvoicePage> {
  GlobalKey<OverRepaintBoundaryState> globalKeyBoundary = GlobalKey();
  final _locationBloc = BlocLocation();
  final _customerBloc = BlocCustomer();
  Uint8List imageInMemory;
  bool inside = false;
  Location _location = Location();
  Customer _customer = Customer();
  var formatter = new DateFormat('dd/MM/yyyy hh:mm aaa');
  final numberFormatter = NumberFormat("#,###");

  @override
  void initState() {
    super.initState();
    _getPreferences();
    _getCustomer(widget.currentInvoice.customer.documentID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            SingleChildScrollView(
              child: OverRepaintBoundary(
                key: globalKeyBoundary,
                child: RepaintBoundary(
                  child: _containerPrint(),
                ),
              ),
            ),
            _buttonPrint(),
          ],
        ),
      ),
    );
  }

  Widget _containerPrint() {
    return Container(
      color: Colors.white,
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white),
            margin: EdgeInsets.only(top: 30),
            child: Center(
              child: Image.asset(
                'assets/images/logo-car-wash.png',
                width: 250,
              ),
            ),
          ),
          Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 9),
                  Center(
                    child: Text(
                      'Spa Car Wash Móvil',
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: 26,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text(
                      _location.director ?? '',
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Régimen Simplificado',
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Center(
                    child: Text(
                      _location.address ?? '',
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Teléfono:  ${_location.phoneNumber}',
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Nit:  ${_location.nit}',
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  SizedBox(height: 14),
                ],
              )),
          _infoInvoice(),
          Container(
            height: 14,
            color: Colors.white,
          ),
          _listServices(),
          _listAdditionalServices(),
          Container(
            height: 24,
            color: Colors.white,
          ),
          Container(
            color: Colors.white,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(height: 2),
                Container(
                  margin: EdgeInsets.only(right: 20),
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          _infoPrice(),
          Container(
            height: 15,
            color: Colors.white,
          ),
          Container(
            child: Center(
              child: Image.asset(
                'assets/images/factura-impr-2.png',
                //width: 250,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoInvoice() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            'Factura # ${widget.currentInvoice.consecutive}',
            style: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w400,
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 7),
          Text(
            formatter.format(widget.currentInvoice.creationDate.toDate()),
            style: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w400,
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 7),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Placa:',
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              Text(
                widget.currentInvoice.placa,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 7),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Marca:',
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              Text(
                widget.currentInvoice.vehicleBrand,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 7),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Cliente:',
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              Text(
                _customer.name ?? '',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 7),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Supervisor:',
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              Text(
                widget.currentInvoice.userCoordinatorName,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 7),
          Text(
            'Servicio de lavado de Autos:',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w400,
              color: Colors.black,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _listServices() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 1000),
      child: ListView.builder(
        itemCount: widget.selectedProducts.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          Product product = widget.selectedProducts[index];
          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: 27),
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      product.productName,
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '\$${numberFormatter.format(product.price)}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _listAdditionalServices() {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: 1000),
      child: ListView.builder(
        itemCount: widget.additionalProducts.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          AdditionalProduct addProduct = widget.additionalProducts[index];
          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: 27),
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      addProduct.productName,
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '\$${numberFormatter.format(double.parse(addProduct.productValue))}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoPrice() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Subtotal:',
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              Text(
                '\$${numberFormatter.format(widget.currentInvoice.subtotal)}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 7),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Iva:',
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              Text(
                '\$${numberFormatter.format(widget.currentInvoice.iva)}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          SizedBox(height: 7),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Total:',
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              Text(
                '\$${numberFormatter.format(widget.currentInvoice.totalPrice)}',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buttonPrint() {
    return Align(
      alignment: Alignment(0.0, 0.9),
      child: Container(
        height: 80,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: RaisedButton(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
            color: Theme.of(context).accentColor,
            child: Text(
              "IMPRIMIR",
              style: TextStyle(
                fontFamily: "Lato",
                decoration: TextDecoration.none,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 19,
              ),
            ),
            onPressed: _capturePng,
          ),
        ),
      ),
    );
  }

  /// Functions

  void _capturePng() async {
    try {
      print('inside');
      inside = true;
      RenderRepaintBoundary boundary =
          globalKeyBoundary.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      //Save Image
      var filePath = await ImagePickerSaver.saveFile(
        fileData: pngBytes,
        title: 'Factura#${widget.currentInvoice.consecutive.toString()}',
        description: 'Factura Carwash',
      );

      //Resize image
      im.Image imageDecode = im.decodePng(pngBytes);
      im.Image thumbnail = im.copyResize(imageDecode, width: 500);

      //Save resized image
      File(filePath).writeAsBytesSync(im.encodePng(thumbnail));

      var resultCompress = await FlutterImageCompress.compressAndGetFile(
          filePath, filePath,
          minWidth: 260, quality: 90);
/*
      var filePath2 = await ImagePickerSaver.saveFile(
        fileData: resultCompress.readAsBytesSync(),
        title: 'Factura#${widget.currentInvoice.consecutive.toString()}',
        description: 'Factura Carwash',
      );
      
 */
      //Set new name based in invoice number
      final partialNewPath =
          filePath.substring(0, filePath.lastIndexOf('/') + 1);
      final fileExtension =
          filePath.substring(filePath.lastIndexOf('.'), filePath.length);
      final newPath = partialNewPath +
          'Factura#${widget.currentInvoice.consecutive.toString()}' +
          fileExtension;

      //Rename Image
      await File(filePath).rename(newPath);

      print('png done');
      setState(() {
        imageInMemory = pngBytes;
        inside = false;
        Navigator.pop(context);
      });
    } catch (e) {
      print(e);
    }
  }

  void _getPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String idLocation = pref.getString(Keys.idLocation);
    _location = await _locationBloc.getLocationById(idLocation);
    setState(() {});
  }

  void _getCustomer(String customerId) async {
    _customer = await _customerBloc.getCustomerByIdCustomer(customerId);
    setState(() {});
  }
}

/// Class and functions print all screen

class UiImagePainter extends CustomPainter {
  final ui.Image image;

  UiImagePainter(this.image);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    // simple aspect fit for the image
    var hr = size.height / image.height;
    var wr = size.width / image.width;

    double ratio;
    double translateX;
    double translateY;
    if (hr < wr) {
      ratio = hr;
      translateX = (size.width - (ratio * image.width)) / 2;
      translateY = 0.0;
    } else {
      ratio = wr;
      translateX = 0.0;
      translateY = (size.height - (ratio * image.height)) / 2;
    }

    canvas.translate(translateX, translateY);
    canvas.scale(ratio, ratio);
    canvas.drawImage(image, new Offset(0.0, 0.0), new Paint());
  }

  @override
  bool shouldRepaint(UiImagePainter other) {
    return other.image != image;
  }
}

class UiImageDrawer extends StatelessWidget {
  final ui.Image image;

  const UiImageDrawer({Key key, this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: UiImagePainter(image),
    );
  }
}

class OverRepaintBoundary extends StatefulWidget {
  final Widget child;

  const OverRepaintBoundary({Key key, this.child}) : super(key: key);

  @override
  OverRepaintBoundaryState createState() => OverRepaintBoundaryState();
}

class OverRepaintBoundaryState extends State<OverRepaintBoundary> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
