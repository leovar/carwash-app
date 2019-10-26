import 'dart:io';

import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/ui/widgets/radio_item.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/vehicle/model/vehicle.dart';
import 'package:car_wash_app/widgets/gradient_back.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:popup_menu/popup_menu.dart';

import 'carousel_cars_widget.dart';
import 'fields_invoice.dart';
import 'header_services.dart';

class FormInvoice extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FormInvoice();
  }
}

class _FormInvoice extends State<FormInvoice> {
  BlocInvoice _blocInvoice;

  ///global variables
  //Esta variable _scaffoldKey se usa para poder abrir el drawer desde un boton diferente al que se coloca por defecto en el AppBar
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  GlobalKey btnAddImage = GlobalKey();
  List<String> imageList = [];
  bool _sendEmail = false;
  List<HeaderServices> vehicleTypeList = new List<HeaderServices>();
  final String cameraTag = "Camara";
  final String galleryTag = "Galeria";
  String _selectSourceImagePicker = "Camara";
  File _imageSelect;

  final _textPlaca = TextEditingController();
  final _textClient = TextEditingController();
  final _textEmail = TextEditingController();
  String _selectOperator = "";
  String _selectCoordinator = "";
  List<String> _listOperators = <String>[];
  List<String> _listCoordinators = <String>[];

  @override
  void initState() {
    super.initState();
    vehicleTypeList.add(HeaderServices(false, "Auto", 38,
        "assets/images/icon_car_admin.png", "assets/images/icon_car.png"));
    vehicleTypeList.add(HeaderServices(
        false,
        "Camioneta",
        37,
        'assets/images/icon_suv_car_admin.png',
        "assets/images/icon_suv_car.png"));
    vehicleTypeList.add(HeaderServices(
        false,
        "Moto",
        34,
        "assets/images/icon_motorcycle_admin.png",
        "assets/images/icon_motorcycle.png"));
    vehicleTypeList[0].isSelected = true;
  }

  @override
  Widget build(BuildContext context) {
    this._blocInvoice = BlocProvider.of(context);
    PopupMenu.context = context;

    if (_imageSelect != null) {
      if (!imageList.contains(_imageSelect.path)) {
        imageList.add(_imageSelect.path);
      }
      _imageSelect = null;
    }

    return Stack(
      children: <Widget>[
        GradientBack(),
        bodyContainer(),
      ],
    );
  }

  bodyContainer() => SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                headerContainerOptions(),
                Container(
                  height: 240,
                  child: CarouselCarsWidget(
                      callbackDeleteImage: _deleteImageList,
                      imgList: imageList),
                ),
                numeroDeFactura(),
                containerFieldsInvoice(),
              ],
            ),
            floatButtonAddImage(),
          ],
        ),
      );

  headerContainerOptions() => Container(
        height: 45,
        decoration: BoxDecoration(shape: BoxShape.rectangle, boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 5.0,
          ),
        ]),
        child: topSelectVehicle(),
      );

  topSelectVehicle() => ListView.builder(
        itemCount: vehicleTypeList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            splashColor: Colors.white,
            onTap: () {
              setState(() {
                vehicleTypeList
                    .forEach((element) => element.isSelected = false);
                vehicleTypeList[index].isSelected = true;
              });
            },
            child: RadioItem(vehicleTypeList[index]),
          );
        },
      );

  numeroDeFactura() => Container(
        height: 70,
        padding: EdgeInsets.only(left: 30),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(right: 15),
              child: Image(
                width: 30,
                image: AssetImage("assets/images/icon_nueva_factura_white.png"),
              ),
            ),
            Text(
              "Nueva Factura - No. 1017",
              style: TextStyle(
                fontFamily: "Lato",
                fontWeight: FontWeight.bold,
                fontSize: 21,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );

  Widget containerFieldsInvoice() {
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
        child: Center(
          child: FieldsInvoice(
            callbackSaveInvoice: _saveInvoice,
            textPlaca: _textPlaca,
            textClient: _textClient,
            textEmail: _textEmail,
            sendEmail: _sendEmail,
            setOperator: _setOperator,
            setCoordinator: _setCoordinator,
            listOperators: _listOperators,
            listCoordinators: _listCoordinators,
          ),
        ),
      ),
    );
  }

  floatButtonAddImage() => Align(
        alignment: Alignment(0.8, 0.8),
        heightFactor: 6,
        child: Container(
          child: FloatingActionButton(
            key: btnAddImage,
            child: Icon(
              Icons.add,
              color: Colors.black,
              size: 30,
            ),
            backgroundColor: Colors.white,
            elevation: 14,
            heroTag: null,
            onPressed: _menuSourceAddImage,
          ),
        ),
      );

  ///Functions

  void _menuSourceAddImage() {
    PopupMenu menu = PopupMenu(
        backgroundColor: Color(0xFF59B258),
        lineColor: Color(0xFF59B258),
        maxColumn: 1,
        items: [
          MenuItem(
              title: cameraTag,
              textStyle: TextStyle(color: Colors.white),
              image: Icon(
                Icons.camera_alt,
                color: Colors.white,
              )),
          MenuItem(
              title: galleryTag,
              textStyle: TextStyle(color: Colors.white),
              image: Icon(
                Icons.image,
                color: Colors.white,
              )),
        ],
        onClickMenu: _onClickMenuImageSelected);
    menu.show(widgetKey: btnAddImage);
  }

  void _deleteImageList(String imageToDelete) {
    imageList.remove(imageToDelete);
    _imageSelect = null;
  }

  void _onClickMenuImageSelected(MenuItemProvider item) {
    _selectSourceImagePicker = item.menuTitle;
    _addImageTour();
    print('Click menu -> ${item.menuTitle}');
  }

  Future _addImageTour() async {
    var imageCapture = await ImagePicker.pickImage(
            source: _selectSourceImagePicker == cameraTag
                ? ImageSource.camera
                : ImageSource.gallery)
        .catchError((onError) => print(onError));

    if (imageCapture != null) {
      setState(() {
        print(imageCapture.lengthSync());
        _cropImage(imageCapture);
      });
    }
  }

  Future<Null> _cropImage(File imageCapture) async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageCapture.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.white,
          toolbarWidgetColor: Theme.of(context).primaryColor,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      iosUiSettings: IOSUiSettings(
        minimumAspectRatio: 1.0,
      ),
    );
    if (croppedFile != null) {
      File fileCompress = await FlutterImageCompress.compressAndGetFile(
        croppedFile.absolute.path,
        croppedFile.path,
        quality: 40,
      );

      setState(() {
        _imageSelect = fileCompress;
      });
    }
  }

  void _setOperator(String selectOperator) {
    _selectOperator = selectOperator;
  }

  void _setCoordinator(String selectCoordinator) {
    _selectCoordinator = selectCoordinator;
  }

  void _saveInvoice() async {
    //Obtiene la referencia del currentUser
    DocumentReference _userRef = await _blocInvoice.getUserReference();

    //Obtiene el tipo de Vehiculo seleccionado
    HeaderServices vehicleTypeSelect =
        vehicleTypeList.firstWhere((HeaderServices type) {
      return type.isSelected == true;
    });

    //Obtiene la referencia del vehiculo seleccionado
    DocumentReference _vehicleTypeRef =
        await _blocInvoice.getVehicleTypeReference(vehicleTypeSelect.text);

    //Obtiene la referencia del vehiculo referenciado en la factura, guarda el vehiculo si no existe
    //DocumentReference _vehicleRef = await _blocInvoice.updateVehicle(_textPlaca.text.trim().toUpperCase());

    final invoice = Invoice(
      totalPrice: 25000,
      subtotal: 3500,
      iva: 2500,
      userOwner: _userRef,
      invoiceImages: imageList,
    );
    _blocInvoice.saveInvoice(invoice);
  }
}
