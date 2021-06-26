import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:car_wash_app/customer/bloc/bloc_customer.dart';
import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/invoice/model/additional_product.dart';
import 'package:car_wash_app/invoice/model/configuration.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/widgets/keys.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:file_utils/file_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker_saver/image_picker_saver.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart' as im;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:permission_handler/permission_handler.dart';
import 'package:mailer/mailer.dart' as ml;
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PrintInvoicePage extends StatefulWidget {
  final Invoice currentInvoice;
  final List<Product> selectedProducts;
  final List<AdditionalProduct> additionalProducts;
  final String customerEmail;
  final Configuration configuration;

  PrintInvoicePage(
      {Key key,
      this.currentInvoice,
      this.selectedProducts,
      this.additionalProducts,
      this.customerEmail,
      this.configuration});

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

  double _logoSize = 290;
  double _invoiceTitle = 26;
  double _textInfoLocationSize = 18;
  double _spaceInfoToServices = 14;
  double _spaceServicesToPrice = 24;
  double _spacePriceNotes = 15;
  double _spaceMarginButton = 16;
  double _textInfoSize = 19;
  double _spaceInfoInvoice = 7;

  @override
  void initState() {
    super.initState();
    _getPreferences();
    _getCustomer(widget.currentInvoice.customer.documentID);
    PermissionHandler().requestPermissions(<PermissionGroup>[
      PermissionGroup.storage,
      PermissionGroup.photos,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context). size. width;
    print(width);
    if(width > 610) {
      _logoSize = 460;
      _invoiceTitle = 42;
      _textInfoLocationSize = 30;
      _spaceInfoToServices = 16;
      _spaceServicesToPrice = 25;
      _spacePriceNotes = 16;
      _spaceMarginButton = 27;
      _textInfoSize = 31;
      _spaceInfoInvoice = 10;
    }

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
            margin: EdgeInsets.only(top: 40),
            child: Center(
              child: Image.asset(
                'assets/images/logo-car-wash.png',
                width: _logoSize,
              ),
            ),
          ),
          Container(
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 3),
                  Center(
                    child: Text(
                      'Spa Car Wash Móvil',
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: _invoiceTitle,
                      ),
                    ),
                  ),
                  SizedBox(height: 6),
                  Center(
                    child: Text(
                      _location.director ?? '',
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                        fontSize: _textInfoLocationSize,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Régimen Simplificado',
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: _textInfoLocationSize,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Center(
                    child: Text(
                      _location.address ?? '',
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: _textInfoLocationSize,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Teléfono:  ${_location.phoneNumber}',
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: _textInfoLocationSize,
                      ),
                    ),
                  ),
                  SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Nit:  ${_location.nit}',
                      style: TextStyle(
                        fontFamily: "Lato",
                        decoration: TextDecoration.none,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        fontSize: _textInfoLocationSize,
                      ),
                    ),
                  ),
                  SizedBox(height: 14),
                ],
              )),
          _infoInvoice(),
          Container(
            height: _spaceInfoToServices,
            color: Colors.white,
          ),
          _listServices(),
          _listAdditionalServices(),
          Container(
            height: _spaceServicesToPrice,
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
            height: _spacePriceNotes,
            color: Colors.white,
          ),
          Container(
            margin: EdgeInsets.only(right: 50, left: 50),
            child: Center(
              child: Text(
                'El operador y la empresa no se hacen responsables por: 1.fallas eléctricas o mecánicas del vehiculo. /2. '
                    'Robo total o parcial del mismo. /3. Bienes olvidados dentro o fuera del vehículo sin inventario. /4. '
                    'No se responde por afectaciones que no se vean debido al polvo. *No se aceptan reclamaciones posteriores '
                    'a la entrega del servicio. *El servicio es independiente al centro comercial.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontSize: _spaceMarginButton,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoInvoice() {
    var _timeDelivery = widget.currentInvoice.timeDelivery ?? '';
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
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontSize: _textInfoSize,
            ),
          ),
          SizedBox(height: _spaceInfoInvoice),
          Text(
            formatter.format(widget.currentInvoice.creationDate.toDate()),
            style: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.w400,
              color: Colors.black,
              fontSize: _textInfoSize,
            ),
          ),
          SizedBox(height: _spaceInfoInvoice),
          Visibility(
            visible: _timeDelivery.isEmpty ? false : true,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'Hora Estimada de Entrega:',
                  style: TextStyle(
                    fontFamily: "Lato",
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: _textInfoSize,
                  ),
                ),
                Text(
                  widget.currentInvoice.timeDelivery ?? '',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: "Lato",
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: _textInfoSize,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: _spaceInfoInvoice),
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
                  fontSize: _textInfoSize,
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
                  fontSize: _textInfoSize,
                ),
              ),
            ],
          ),
          SizedBox(height: _spaceInfoInvoice),
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
                  fontSize: _textInfoSize,
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
                  fontSize: _textInfoSize,
                ),
              ),
            ],
          ),
          SizedBox(height: _spaceInfoInvoice),
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
                  fontSize: _textInfoSize,
                ),
              ),
              Flexible(
                child: Text(
                  _customer.name ?? '',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: "Lato",
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: _textInfoSize,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: _spaceInfoInvoice),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Telefono:',
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: _textInfoSize,
                ),
              ),
              Text(
                _customer.phoneNumber ?? '',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: _textInfoSize,
                ),
              ),
            ],
          ),
          SizedBox(height: _spaceInfoInvoice),
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
                  fontSize: _textInfoSize,
                ),
              ),
              Flexible(
                child: Text(
                  widget.currentInvoice.userCoordinatorName,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: "Lato",
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: _textInfoSize,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: _spaceInfoInvoice),
          Text(
            'Servicio de lavado de Autos:',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: _textInfoSize,
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
              margin: EdgeInsets.only(bottom: _spaceInfoInvoice),
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
                        fontSize: _textInfoSize,
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
                        fontSize: _textInfoSize,
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
              margin: EdgeInsets.only(bottom: _spaceInfoInvoice),
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
                        fontSize: _textInfoSize,
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
                        fontSize: _textInfoSize,
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
          Visibility(
            visible: _location.printIva ?? true,
            child: Row(
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
                    fontSize: _textInfoSize,
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
                    fontSize: _textInfoSize,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: _spaceInfoInvoice),
          Visibility(
            visible: _location.printIva ?? true,
            child: Row(
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
                    fontSize: _textInfoSize,
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
                    fontSize: _textInfoSize,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: _spaceInfoInvoice),
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
                  fontSize: _textInfoSize,
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
                  fontSize: _textInfoSize,
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
      MessagesUtils.showAlertWithLoading(context: context, title: 'Imprimiendo Factura').show();

      print('inside');
      inside = true;
      RenderRepaintBoundary boundary =
      globalKeyBoundary.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 2.5);
      ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      //Save Image
      var filePath = await ImagePickerSaver.saveFile(
        fileData: pngBytes,
        title: 'Factura#${widget.currentInvoice.consecutive.toString()}',
        description: 'Factura Carwash',
      );

      if (filePath.isEmpty) {
        final Map<dynamic,dynamic> filePathGet = await ImageGallerySaver.saveImage(pngBytes);
        //Fluttertoast.showToast(msg: "$filePathGet", toastLength: Toast.LENGTH_LONG);
        filePath = filePathGet['filePath'].substring(filePathGet['filePath'].indexOf('storage') - 1, filePathGet['filePath'].length);
      }

      //Save resized image
      im.Image imageDecode = im.decodePng(pngBytes);
      im.Image thumbnail = im.copyResize(imageDecode, width: 560);
      File(filePath).writeAsBytesSync(im.encodePng(thumbnail));

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

      if(widget.currentInvoice.sendEmailInvoice != null && widget.currentInvoice.sendEmailInvoice) {
        _sendMail(newPath);
      }

      print('png done');
      setState(() {
        imageInMemory = pngBytes;
        inside = false;
        Navigator.pop(context); //cierra el mensaje de loading
        Navigator.pop(context); //cierra la ventana
      });
    } catch (e) {
      Navigator.pop(context);
      MessagesUtils.showAlert(context: context, title: 'Error guardando la imagen $e').show();
    }
  }

  Iterable<ml.Attachment> toAt(Iterable<String> attachments) =>
      (attachments ?? []).map((a) => ml.FileAttachment(File(a)));

  void _sendMail(String imagePath) async {
    String username = widget.configuration.emailFrom;
    String password = widget.configuration.passFrom;
    String domainSmtp = widget.configuration.smtpFrom;

    if (widget.customerEmail.isNotEmpty) {
      final emailSplit = widget.customerEmail.split(',');
      final smtpServer = gmail(username, password);
      final message = ml.Message()
        ..from = ml.Address(username, 'Spa Car Wash Movil')
      //..recipients.add(element.trim())
        ..ccRecipients.addAll(emailSplit.map((e) => e.trim()))
      //..bccRecipients.add(Address('bccAddress@example.com'))
        ..subject = 'Tu factura Spa Car Wash Movil :: 😀 :: ${DateTime.now()}'
      //..text = 'This is the plain text.\nThis is line 2 of the text part.'
        ..html = "<h1>Hola</h1>\n<p>Estamos felices con tu visita en nuestro Spa de Autos. Gracias por elegirnos. Adjuntamos la factura del servicio realizado.</p>"
        ..attachments.addAll(toAt([imagePath] as Iterable<String>));

      try {
        final sendReport = await ml.send(message, smtpServer, timeout: Duration(seconds: 15));
        print('Message sent: ' + sendReport.toString());
        Fluttertoast.showToast(msg: "Correo enviado", toastLength: Toast.LENGTH_LONG);
      } on ml.MailerException catch (e) {
        print('Message not sent.');
        Fluttertoast.showToast(msg: "Error enviando el correo: ${e.message}", toastLength: Toast.LENGTH_LONG);
      }
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
