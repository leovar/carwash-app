import 'dart:io';
import 'dart:typed_data';

import 'package:car_wash_app/customer/bloc/bloc_customer.dart';
import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/additional_product.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/model/invoice_history_list.dart';
import 'package:car_wash_app/invoice/ui/screens/draw_page.dart';
import 'package:car_wash_app/invoice/ui/screens/print_invoice_page.dart';
import 'package:car_wash_app/invoice/ui/widgets/fields_products.dart';
import 'package:car_wash_app/invoice/ui/widgets/info_last_services_by_vehicle.dart';
import 'package:car_wash_app/invoice/ui/widgets/print_invoice.dart';
import 'package:car_wash_app/invoice/ui/widgets/radio_item.dart';
import 'package:car_wash_app/invoice/ui/widgets/text_field_input.dart';
import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/product/bloc/product_bloc.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/vehicle/bloc/bloc_vehicle.dart';
import 'package:car_wash_app/vehicle/model/vehicle.dart';
import 'package:car_wash_app/widgets/gradient_back.dart';
import 'package:car_wash_app/widgets/info_header_container.dart';
import 'package:car_wash_app/widgets/keys.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:image/image.dart' as imagePack;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

import '../../model/header_services.dart';
import 'carousel_cars_widget.dart';
import 'fields_invoice.dart';
import 'fields_menu_invoice.dart';

class FormInvoice extends StatefulWidget {
  final Invoice editInvoice;

  FormInvoice(this.editInvoice);

  @override
  State<StatefulWidget> createState() => _FormInvoice();
}

class _FormInvoice extends State<FormInvoice> {
  BlocInvoice _blocInvoice;
  final _productBloc = ProductBloc();
  final _customerBloc = BlocCustomer();
  final _blocVehicle = BlocVehicle();
  final _userBloc = UserBloc();
  final _locationBloc = BlocLocation();
  bool _enableForm;
  bool _editForm = true;
  bool _editOperator = false;
  bool _enablePerIncidence = false;

  ///global variables
  //Esta variable _scaffoldKey se usa para poder abrir el drawer desde un boton diferente al que se coloca por defecto en el AppBar
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  GlobalKey btnAddImage = GlobalKey();
  List<String> imageList = [];
  String _tagSpecialService = 'Especial';
  String _tagSimpleService = 'Sencillo';
  bool _sendEmail = false;
  bool _approveDataProcessing = false;
  Uint8List _imageFirmInMemory;
  String _placa = '';
  List<HeaderServices> vehicleTypeList = new List<HeaderServices>();
  HeaderServices vehicleTypeSelected;
  final String cameraTag = "Camara";
  final String galleryTag = "Galeria";
  String _selectSourceImagePicker = "Camara";
  File _imageSelect;
  FocusNode _clientFocusNode;
  DocumentReference _locationReference;
  String _locationName;
  String _idLocation;
  String _initConsecLocation;
  String _finalConsecLocation;
  String _selectBrand = '';
  String _selectedBrandReference = '';
  String _selectColor = '';
  String _selectTypeSex = '';

  final _textPlaca = TextEditingController();
  final _textClient = TextEditingController();
  final _textEmail = TextEditingController();
  final _textPhoneNumber = TextEditingController();
  final _textNeighborhood = TextEditingController();
  final _textBirthDate = TextEditingController();
  final _textTimeDelivery = TextEditingController();
  final _textObservation = TextEditingController();
  final _textIncidence = TextEditingController();
  String _selectOperator = "";
  String _selectCoordinator = "";
  List<Product> _listProduct = <Product>[];
  List<AdditionalProduct> _listAdditionalProducts = <AdditionalProduct>[];
  bool _validatePlaca = false;
  Customer _customer;
  DocumentReference _vehicleReference;
  int _listOperatorsCount = 0;
  int _listCoordinatorsCount = 0;
  int _countBrands = 0;
  int _countBrandReferences = 0;
  int _countColors = 0;

  @override
  void initState() {
    super.initState();
    _enableForm = false;
    _clientFocusNode = FocusNode();
    _listOperatorsCount = 0;
    _listCoordinatorsCount = 0;
    _countBrands = 0;
    _countColors = 0;
    //TODO traer estos datos desde la base de datos y cargarlos en un widget aparte con un stream
    vehicleTypeList.add(HeaderServices(false, "Auto", 1, 38,
        "assets/images/icon_car_admin.png", "assets/images/icon_car.png"));
    vehicleTypeList.add(HeaderServices(
        false,
        "Camioneta",
        2,
        37,
        'assets/images/icon_suv_car_admin.png',
        "assets/images/icon_suv_car.png"));
    vehicleTypeList.add(HeaderServices(
        false,
        "Moto",
        3,
        34,
        "assets/images/icon_motorcycle_admin.png",
        "assets/images/icon_motorcycle.png"));
    vehicleTypeList.add(HeaderServices(
        false,
        "Bicicleta",
        4,
        34,
        "assets/images/icon_motorcycle_admin.png",
        "assets/images/icon_motorcycle.png"));
    vehicleTypeList[0].isSelected = true;
    vehicleTypeSelected = vehicleTypeList[0];
    if (widget.editInvoice != null) {
      _editInvoice(widget.editInvoice);
      _editForm = false;
    }
  }

  @override
  void dispose() {
    _clientFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    this._blocInvoice = BlocProvider.of(context);
    PopupMenu.context = context;
    getPreferences();

    if (_imageSelect != null) {
      if (!imageList.contains(_imageSelect.path)) {
        imageList.add(_imageSelect.path);
      }
      _imageSelect = null;
    }

    return WillPopScope(
      child: Stack(
        children: <Widget>[
          GradientBack(),
          bodyContainer(),
        ],
      ),
      onWillPop: () {
        if (_textPlaca.text.isNotEmpty) {
          return _alertBackButton();
        } else {
          return Future(() => true);
        }
      },
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
                    imgList: imageList,
                    editForm: _editForm,
                  ),
                ),
                _invoiceNumber(),
                containerFieldsInvoice(),
              ],
            ),
            floatButtonAddImage(),
          ],
        ),
      );

  headerContainerOptions() => Container(
        height: 55,
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
            onTap: _editForm
                ? () {
                    setState(() {
                      vehicleTypeList
                          .forEach((element) => element.isSelected = false);
                      vehicleTypeList[index].isSelected = true;
                      vehicleTypeSelected = vehicleTypeList[index];
                      _listAdditionalProducts = <AdditionalProduct>[];
                      _listProduct = <Product>[];
                    });
                  }
                : null,
            child: RadioItem(vehicleTypeList[index]),
          );
        },
      );

  Widget _invoiceNumber() {
    return InfoHeaderContainer(
      image: 'assets/images/icon_nueva_factura_white.png',
      textInfo: _editForm
          ? 'Nueva Factura'
          : 'Factura Nro ${widget.editInvoice.consecutive}',
    );
  }

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
          child: Column(
            children: <Widget>[
              FieldsInvoice(
                textPlaca: _textPlaca,
                validatePlaca: _validatePlaca,
                textClient: _textClient,
                textEmail: _textEmail,
                textPhoneNumber: _textPhoneNumber,
                textNeighborhood: _textNeighborhood,
                textBirthDate: _textBirthDate,
                textTimeDelivery: _textTimeDelivery,
                sendEmail: _sendEmail,
                finalEditPlaca: _onFinalEditPlaca,
                enableForm: _enableForm,
                focusClient: _clientFocusNode,
                autofocusPlaca:
                    (widget.editInvoice == null && _listCoordinatorsCount == 0)
                        ? true
                        : false,
                editForm: _editForm,
              ),
              SizedBox(height: 9),
              FieldsMenusInvoice(
                listCountOperators: _listOperatorsCount,
                listCountCoordinators: _listCoordinatorsCount,
                listCountBrands: _countBrands,
                listCountColors: _countColors,
                listCountBrandReference: _countBrandReferences,
                cbHandlerOperator: _setHandlerUsersOperator,
                cbHandlerCoordinator: _setHandlerUserCoordinator,
                cbHandlerVehicleBrand: _setHandlerVehicleBrand,
                cbHandlerVehicleBrandReference: _setHandlerBrandReferences,
                cbHandlerVehicleColor: _setHandlerVehicleColor,
                cbHandlerTypeSex: _setHandlerTypeSex,
                locationReference: _locationReference,
                selectedOperator: _selectOperator,
                selectedCoordinator: _selectCoordinator,
                selectedVehicleBrand: _selectBrand,
                selectVehicleBrandReference: _selectedBrandReference,
                selectedVehicleColor: _selectColor,
                selectedTypeSex: _selectTypeSex,
                uidVehicleType: vehicleTypeSelected.uid,
                enableForm: _enableForm,
                editOperator: _editOperator,
              ),
              SizedBox(height: 9),
              TextFieldInput(
                textController: _textObservation,
                labelText: 'Observaciones',
                inputType: TextInputType.multiline,
                maxLines: null,
                enable: _enableForm,
              ),
              Visibility(
                visible: !_editForm,
                child: Container(
                  margin: EdgeInsets.only(top: 9.0),
                  child: TextFieldInput(
                    textController: _textIncidence,
                    labelText: 'Incidentes',
                    inputType: TextInputType.multiline,
                    maxLines: null,
                    enable: _enablePerIncidence,
                  ),
                ),
              ),
              SizedBox(height: 9),
              FieldsProducts(
                callbackProductsList: _setProductsDb,
                productListCallback: _listProduct,
                callbackAdditionalProdList: _setAdditionalProducts,
                additionalProductListCb: _listAdditionalProducts,
                vehicleTypeSelect: vehicleTypeSelected,
                enableForm: _enableForm,
                idLocation: _idLocation,
                selectedProductsCount:
                    _listProduct.where((f) => f.isSelected).toList().length +
                        _listAdditionalProducts.length,
                editForm: _editForm,
              ),
              SizedBox(height: 9),
              Visibility(
                visible: _editForm,
                child: _showDraw(),
              ),
              Visibility(
                visible: _validateEnableSave(),
                child: _saveInvoiceButton(),
              ),
              Visibility(
                visible: !_editForm,
                child: _rePrintInvoice(),
              ),
              SizedBox(height: 9),
              //_printInvoiceTest(),
              //SizedBox(height: 9),
            ],
          ),
        ),
      ),
    );
  }

  floatButtonAddImage() => Align(
        alignment: Alignment(0.8, 0.9),
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
            onPressed: _enableForm ? _menuSourceAddImage : null,
          ),
        ),
      );

  Widget _showDraw() {
    return Container(
      height: 80,
      child: Align(
        alignment: Alignment.center,
        child: ButtonTheme(
          minWidth: 230.0,
          height: 50,
          child: RaisedButton(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            color: Color(0xFF59B258),
            child: Text(
              "FIRMAR",
              style: TextStyle(
                fontFamily: "Lato",
                decoration: TextDecoration.none,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 19,
              ),
            ),
            onPressed: _enableForm
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DrawPage(
                          changeValueApproveData:
                              _callBackApproveDataprocessing,
                          callBackChargeImageFirm: _callBackChargeFirm,
                          approveDataProcessing: _approveDataProcessing,
                        ),
                      ),
                    );
                  }
                : null,
          ),
        ),
      ),
    );
  }

  Widget _saveInvoiceButton() {
    return Container(
      height: 80,
      child: Align(
        alignment: Alignment.center,
        child: ButtonTheme(
          minWidth: 230.0,
          height: 50,
          child: RaisedButton(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            color: Theme.of(context).accentColor,
            child: Text(
              "GUARDAR",
              style: TextStyle(
                fontFamily: "Lato",
                decoration: TextDecoration.none,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 19,
              ),
            ),
            onPressed: _validateEnableSave() ? _saveInvoice : null,
          ),
        ),
      ),
    );
  }

  Widget _rePrintInvoice() {
    return Container(
      height: 80,
      child: Align(
        alignment: Alignment.center,
        child: ButtonTheme(
          minWidth: 230.0,
          height: 50,
          child: RaisedButton(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            color: Theme.of(context).accentColor,
            child: Text(
              "IMPRIMIR FACTURA",
              style: TextStyle(
                fontFamily: "Lato",
                decoration: TextDecoration.none,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 19,
              ),
            ),
            onPressed: () {
              if (widget.editInvoice != null) {
                _printInvoice(
                  widget.editInvoice,
                  _listProduct.where((f) => f.isSelected).toList(),
                  _listAdditionalProducts,
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _printInvoiceTest() {
    return Container(
      height: 80,
      child: Align(
        alignment: Alignment.center,
        child: RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
          color: Theme.of(context).accentColor,
          child: Text(
            "IMPRIMIR TEST",
            style: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 19,
            ),
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PrintInvoice()));
          },
        ),
      ),
    );
  }

  ///Functions

  ///Image Functions
  void _menuSourceAddImage() {
    PopupMenu menu = PopupMenu(
        backgroundColor: Theme.of(context).accentColor,
        lineColor: Theme.of(context).accentColor,
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
      // Esta parte de compress se coloca por que no va con crop, si fuera con crop esta parte ya esta en el crop
      final dir = await path_provider.getTemporaryDirectory();
      final targetPath = dir.absolute.path + "/${imageCapture.path.substring(imageCapture.path.length-10 ,imageCapture.path.length)}"; //dir.absolute.path + "/temp${imageList.length}.jpg";
      final fileCompress = await FlutterImageCompress.compressAndGetFile(
          imageCapture.absolute.path,
          targetPath,
          quality: 30,
          autoCorrectionAngle: true,
          format: CompressFormat.jpeg,
      );
      setState(() {
        _imageSelect = fileCompress;
        // el crop es comentado por que el cliente quiere que asi como se tome la foto quede.
        //_cropImage(imageCapture);
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
        quality: 40
      );

      setState(() {
        _imageSelect = fileCompress;
      });
    }
  }

  ///Functions Select Menu
  void _setHandlerUsersOperator(
      String operatorSelect, int operatorsCount, int operationType) {
    if (operationType == 1) {
      _selectOperator = operatorSelect;
    } else {
      _listOperatorsCount = operatorsCount;
    }
  }

  void _setHandlerUserCoordinator(
      String selectCoordinator, int countList, int operationType) {
    if (operationType == 1) {
      _selectCoordinator = selectCoordinator;
    } else {
      _listCoordinatorsCount = countList;
    }
  }

  //operationType 1=setBrand, 2= setCountBrands
  void _setHandlerVehicleBrand(
      String brand, int countBrands, int operationType) {
    if (operationType == 1) {
      _selectBrand = brand;
    } else {
      _countBrands = countBrands;
    }
  }

  //operationType 1=setBrand, 2= setCountBrands
  void _setHandlerBrandReferences(
      String brandReference, int countBrands, int operationType) {
    if (operationType == 1) {
      _selectedBrandReference = brandReference;
    } else {
      _countBrandReferences = countBrands;
    }
  }

  //operationType 1=setColor, 2= setCountColors
  void _setHandlerVehicleColor(
      String vehicleColor, int countColors, int operationType) {
    if (operationType == 1) {
      _selectColor = vehicleColor;
    } else {
      _countColors = countColors;
    }
  }

  //Type sex
  void _setHandlerTypeSex(String typeSex, int countTypeSex, int operationType) {
    _selectTypeSex = typeSex;
  }

  ///Functions Image Firma
  void _callBackApproveDataprocessing(bool value) {
    _approveDataProcessing = value;
  }

  void _callBackChargeFirm(Uint8List imageFirm) {
    _imageFirmInMemory = imageFirm;
  }

  ///Functions Services or Products
  void _setProductsDb(List<Product> productListSelected) {
    _listProduct = productListSelected;
  }

  void _setAdditionalProducts(List<AdditionalProduct> additionalProductList) {
    _listAdditionalProducts = additionalProductList;
  }

  ///Function validate exist customer
  /// After digit placa validate Vehicle and Customer
  void _onFinalEditPlaca() {
    _placa = _textPlaca.text ?? '';

    if (_placa.isEmpty) {
      setState(() {
        _validatePlaca = true;
        _enableForm = false;
      });
    } else {
      if (_placa.length > 2) {
        _validatePlaca = false;
        _enableForm = true;

        //Get vehicle if exist
        _blocVehicle
            .getVehicleReferenceByPlaca(_placa)
            .then((DocumentReference vehicleRef) {
          _vehicleReference = vehicleRef;

          if (vehicleRef != null) {
            _blocVehicle.getVehicleById(vehicleRef.documentID)
                .then((vehicle){
              _selectBrand = vehicle.brand;
              _selectColor = vehicle.color;
              _selectedBrandReference = vehicle.brandReference;
              setState(() {

              });
            });
          } else {
            _selectBrand = '';
            _selectColor = '';
            _selectedBrandReference = '';
            setState(() {

            });
          }

          //Validate services from the last 2 months
          if (_vehicleReference != null) {
            _getInvoicesForPlaca(_placa);
          }

          //Validate if Customer exist for this vehicle
          if (_vehicleReference != null) {
            _customerBloc
                .getCustomerByVehicle(_vehicleReference)
                .then((Customer customer) {
              setState(() {
                if (customer == null) {
                  _cleanTextFields();
                } else {
                  _customer = customer;
                  _textClient.text = customer.name;
                  _textEmail.text = customer.email;
                  _textPhoneNumber.text = customer.phoneNumber;
                  _textNeighborhood.text = customer.neighborhood;
                  _textBirthDate.text = customer.birthDate;
                  _selectTypeSex = customer.typeSex;
                }
              });
            });
          } else {
            setState(() {
              _cleanTextFields();
            });
          }
        });
      } else {
        setState(() {
          _cleanTextFields();
          //_validatePlaca = true;
          _enableForm = false;
        });
      }
    }
  }

  void _cleanTextFields() {
    _textClient.text = '';
    _textEmail.text = '';
    _textPhoneNumber.text = '';
    _textBirthDate.text = '';
    _textNeighborhood.text = '';
    _selectTypeSex = '';
    //FocusScope.of(context).requestFocus(_clientFocusNode);
  }

  void getPreferences() async {
    //Get preferences with location and get location reference
    SharedPreferences pref = await SharedPreferences.getInstance();
    _locationName = pref.getString(Keys.locationName);
    _initConsecLocation = pref.getString(Keys.locationInitCount);
    _finalConsecLocation = pref.getString(Keys.locationFinalCount);
    _idLocation = pref.getString(Keys.idLocation);
    _locationReference = await _locationBloc.getLocationReference(_idLocation);
  }

  // Get last invoices per vehicle
  void _getInvoicesForPlaca(String placa) async {
    List<Invoice> listInvoicesByVehicle =
        await _blocInvoice.getListInvoicesByVehicle(placa) ?? [];
    if (listInvoicesByVehicle.length > 0) {
      List<InvoiceHistoryList> invoiceHistoryList = [];
      listInvoicesByVehicle.forEach((vehicleInvoice) async {
        List<Product> listProducts =
            await _blocInvoice.getProductsByInvoice(vehicleInvoice.id);
        InvoiceHistoryList invoiceHistory = InvoiceHistoryList(
          vehicleInvoice.creationDate,
          vehicleInvoice.consecutive.toString(),
          listProducts.first.productName,
            vehicleInvoice.totalPrice
        );
        invoiceHistoryList.add(invoiceHistory);
        if (invoiceHistoryList.length == listInvoicesByVehicle.length) {
          Alert(
              context: context,
              title: 'Historia',
              style: MessagesUtils.alertStyle,
              content: InfoLastServicesByVehicle(
                listHistoryInvoices: invoiceHistoryList,
              ),
              buttons: [
                DialogButton(
                  color: Theme.of(context).accentColor,
                  child: Text(
                    'ACEPTAR',
                    style: Theme.of(context).textTheme.button,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {});
                  },
                )
              ]).show();
        }
      });
    }
  }

  ///Functions Save Invoice
  void _saveInvoice() async {

    bool _haveServiceSpecial = false;
    //validate internet connection if have images
    if (imageList.length > 0) {
      var connectivityResult = await (Connectivity().checkConnectivity());
      var connectionMobile = connectivityResult == ConnectivityResult.mobile;
      var connectionWifi = connectivityResult == ConnectivityResult.wifi;
      if (!connectionMobile && !connectionWifi) {
        MessagesUtils.showAlert(context: context, title: 'No tiene conexión a internet! no se pueden guardar las imagenes').show();
        return;
      }
    }

    String validateMessage = _validateFields();
    if (validateMessage.isEmpty) {
      //Open message Saving
      MessagesUtils.showAlertWithLoading(context: context, title: 'Guardando')
          .show();

      try {
        DocumentReference _vehicleTypeRef;  //esta referencia debe traerse de la bd, en el momento se construye en la app
        DocumentReference _customerReference;
        DocumentReference _operatorReference;
        DocumentReference _coordinatorReference;
        double _total = 0;
        double _iva = 0;
        double _subTotal = 0;

        //Get Current user reference
        DocumentReference _userRef = await _userBloc.getCurrentUserReference();

        //Get Operator reference
        if (_selectOperator.isNotEmpty) {
          _operatorReference =
              await _userBloc.getUserReferenceByUserName(_selectOperator);
        }

        //Get Coordinator reference
        if (_selectCoordinator.isNotEmpty) {
          _coordinatorReference =
              await _userBloc.getUserReferenceByUserName(_selectCoordinator);
        }

        //Get Vehicle reference, save if not exist
        if (_vehicleReference == null) {
          Vehicle updateVehicle = Vehicle(
            brand: _selectBrand,
            model: '',
            placa: _textPlaca.text.trim(),
            color: _selectColor,
            vehicleType: vehicleTypeSelected.text, //_vehicleTypeRef,
            creationDate: Timestamp.now(),
            brandReference: _selectedBrandReference,
          );
          DocumentReference vehicleRef =
              await _blocVehicle.updateVehicle(updateVehicle);
          _vehicleReference = vehicleRef;
        }

        //Get Customer reference or create customer or update customer
        if (_customer == null) {
          List<DocumentReference> listVehicles = <DocumentReference>[];
          listVehicles.add(_vehicleReference);

          Customer customer = Customer(
            name: _textClient.text.trim(),
            address: '',
            phoneNumber: _textPhoneNumber.text.trim(),
            birthDate: _textBirthDate.text,
            neighborhood: _textNeighborhood.text,
            typeSex: _selectTypeSex,
            email: _textEmail.text.trim(),
            creationDate: Timestamp.now(),
            vehicles: listVehicles,
          );
          DocumentReference customerRef =
              await _customerBloc.updateCustomer(customer);
          _customerReference = customerRef;
        } else {
          if (!_customer.vehicles.contains(_vehicleReference)) {
            _customer.vehicles.add(_vehicleReference);
          }

          Customer customerUpdate = Customer.copyWith(
            origin: _customer,
            name: _textClient.text.trim(),
            phoneNumber: _textPhoneNumber.text.trim(),
            email: _textEmail.text.trim(),
            birthDate: _textBirthDate.text,
            neighborhood: _textNeighborhood.text,
            typeSex: _selectTypeSex,
          );
          _customerReference =
              await _customerBloc.updateCustomer(customerUpdate);
        }

        //Get products and values
        _listProduct.forEach((product) {
          //If at least only one services is special
          if (product.productType == _tagSpecialService)
            _haveServiceSpecial = true;

          // Get pricing information
          if (product.isSelected) {
            int _subT =
                ((product.price * 100) / (100 + product.ivaPercent)).round();
            int _ivaProd = ((_subT * product.ivaPercent) / 100).round();
            // se comenta por que por los decimales la suma de subtotal e iva no siempre da el total, por lo cual se seguira guardando el subtotal como una resta del total menos el iva
            _subTotal = _subTotal + (product.price - _ivaProd); //_subT
            _iva = _iva + _ivaProd;
            _total = _total + product.price;
          }
        });
        _listAdditionalProducts.forEach((addProduct) {
          int _subT = ((double.parse(addProduct.productValue ?? '0') * 100) /
                  (100 + addProduct.ivaPercent ?? 0))
              .round();
          int _ivaProd = ((_subT * addProduct.ivaPercent ?? 0) / 100).round();
          _subTotal = _subTotal +
              (double.parse(addProduct.productValue ?? '0') -
                  _ivaProd); //_subT;
          _iva = _iva + _ivaProd;
          _total = _total + double.parse(addProduct.productValue ?? '0');
        });

        //Get Consecutive
        int _consecutive =
            await _blocInvoice.getLastConsecutiveByLocation(_locationReference);
        if (_consecutive == 0) {
          _consecutive = int.parse(_initConsecLocation);
        } else {
          _consecutive++;
        }

        final invoice = Invoice(
          id: widget.editInvoice != null ? widget.editInvoice.id : null,
          consecutive: widget.editInvoice != null
              ? widget.editInvoice.consecutive
              : _consecutive,
          customer: _customerReference,
          phoneNumber: _textPhoneNumber.text.trim(),
          vehicle: _vehicleReference,
          placa: _textPlaca.text.trim(),
          uidVehicleType: vehicleTypeSelected.uid,
          location: widget.editInvoice != null
              ? widget.editInvoice.location
              : _locationReference,
          locationName: widget.editInvoice != null
              ? widget.editInvoice.locationName
              : _locationName,
          totalPrice: widget.editInvoice != null
              ? widget.editInvoice.totalPrice
              : _total,
          subtotal: widget.editInvoice != null
              ? widget.editInvoice.subtotal
              : _subTotal,
          iva: widget.editInvoice != null ? widget.editInvoice.iva : _iva,
          userOwner: widget.editInvoice != null
              ? widget.editInvoice.userOwner
              : _userRef,
          userOperator: _operatorReference,
          userOperatorName: _selectOperator,
          userCoordinator: _coordinatorReference,
          userCoordinatorName: _selectCoordinator,
          creationDate: widget.editInvoice != null
              ? widget.editInvoice.creationDate
              : Timestamp.now(),
          invoiceImages: imageList,
          imageFirm: _imageFirmInMemory,
          approveDataProcessing: _approveDataProcessing,
          vehicleBrand: _selectBrand,
          brandReference: _selectedBrandReference,
          vehicleColor: _selectColor,
          timeDelivery: _textTimeDelivery.text,
          observation: _textObservation.text.trim(),
          incidence: _textIncidence.text.trim(),
          haveSpecialService: _haveServiceSpecial,
        );
        DocumentReference invoiceReference =
            await _blocInvoice.saveInvoice(invoice);
        String invoiceId = invoiceReference.documentID;
        Invoice _currentInvoiceSaved =
            await _blocInvoice.getInvoiceById(invoiceId);

        //Save products list
        List<Product> _selectedProducts =
            _listProduct.where((f) => f.isSelected).toList();
        if (_selectedProducts.length > 0) {
          _blocInvoice.saveInvoiceProduct(invoiceId, _selectedProducts);
        }

        //Save additional products list
        if (_listAdditionalProducts.length > 0) {
          _blocInvoice.saveInvoiceAdditionalProducts(
              invoiceId, _listAdditionalProducts);
        }

        //Close screen
        Navigator.pop(context); //Close popUp Save
        Navigator.pop(context); //Close form Create Invoice

        if (widget.editInvoice == null) {
          _printInvoice(_currentInvoiceSaved, _selectedProducts, _listAdditionalProducts);
        }

        //MessagesUtils.showAlert(context: context, title: 'Factura Guardada').show();

      } on PlatformException catch (e) {
        print('$e');
        MessagesUtils.showAlert(
            context: context, title: 'Error al guardar la factura');
      } catch (error) {
        print('$error');
        MessagesUtils.showAlert(
            context: context, title: 'Error al guardar la factura');
      }
    } else {
      MessagesUtils.showAlert(context: context, title: validateMessage).show();
    }
  }

  ///Validations fields
  String _validateFields() {
    //Validate caracteres de placa para autos y camionetas
    if (vehicleTypeSelected.uid == 1 || vehicleTypeSelected.uid == 2) {
      if (_textPlaca.text.length < 6) {
        return 'La placa debe tener minimo 6 caracteres';
      }
    }
    //Validate products
    List<Product> _selectedProducts =
        _listProduct.where((f) => f.isSelected).toList();
    if (_selectedProducts.length <= 0 && _listAdditionalProducts.length <= 0) {
      return 'Debe agregar servicios';
    }
    //Validate client
    if (_textClient.text.trim().isEmpty ||
        _textPhoneNumber.text.trim().isEmpty) {
      return 'Falta llenar Telefono o Nombre del Cliente';
    }
    if (_textClient.text.trim().length < 3) {
      return 'El nombre del cliente debe tener como mínimo 3 caracteres';
    }
    if (_textPhoneNumber.text.trim().length < 10) {
      return 'El teléfono del cliente está incompleto';
    }
    if (_selectCoordinator.isEmpty) {
      return 'Debe selecionar un Coordinador';
    }
    if (_selectBrand.isEmpty) {
      return 'Debe seleccionar la marca del vehículo';
    }
    if (_selectColor.isEmpty) {
      return 'Debe seleccionar el color del vehículo';
    }
    return '';
  }

  ///Set Fields Invoice to Edit
  void _editInvoice(Invoice invoiceToEdit) async {
    _textPlaca.text = invoiceToEdit.placa;
    _selectOperator = invoiceToEdit.userOperatorName;
    _selectCoordinator = invoiceToEdit.userCoordinatorName;
    _selectBrand = invoiceToEdit.vehicleBrand ?? '';
    _selectedBrandReference = invoiceToEdit.brandReference ?? '';
    _selectColor = invoiceToEdit.vehicleColor ?? '';
    if (_selectOperator.isEmpty) {
      _editOperator = true;
    }
    _approveDataProcessing = invoiceToEdit.approveDataProcessing;
    _textTimeDelivery.text = invoiceToEdit.timeDelivery;
    _textObservation.text = invoiceToEdit.observation;
    _textIncidence.text = invoiceToEdit.incidence;

    //get vehicle reference
    _vehicleReference = await _blocVehicle.getVehicleReferenceByPlaca(invoiceToEdit.placa);

    //get customer information
    _customer = await _customerBloc
        .getCustomerByIdCustomer(invoiceToEdit.customer.documentID);
    _textClient.text = _customer.name;
    _textEmail.text = _customer.email;
    _textPhoneNumber.text = _customer.phoneNumber;
    _textBirthDate.text = _customer.birthDate;
    _textNeighborhood.text = _customer.neighborhood;
    _selectTypeSex = _customer.typeSex;
    vehicleTypeList.forEach((element) => element.isSelected = false);
    vehicleTypeSelected = vehicleTypeList
        .firstWhere((f) => f.uid == invoiceToEdit.uidVehicleType);
    setState(() {
      vehicleTypeList[vehicleTypeList.indexOf(vehicleTypeSelected)].isSelected =
          true;
    });
    List<Product> listProducts =
        await _blocInvoice.getProductsByInvoice(invoiceToEdit.id);
    List<Product> productEditList = <Product>[];
    listProducts.forEach((prodSelected) {
      if (!prodSelected.isAdditional) {
        prodSelected.newProduct = false;
        productEditList.add(prodSelected);
      } else {
        AdditionalProduct addProd = AdditionalProduct(
          prodSelected.productName,
          prodSelected.price.toString(),
          prodSelected.ivaPercent,
          false,
        );
        _listAdditionalProducts.add(addProd);
      }
    });
    setState(() {
      _listProduct = productEditList;
    });
    List<String> imagesList =
        await _blocInvoice.getInvoiceImages(invoiceToEdit.id);
    setState(() {
      imageList = imagesList;
    });
  }

  void _printInvoice(Invoice invoicePrint, List<Product> listProducts,
      List<AdditionalProduct> listAddProducts) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrintInvoicePage(
          currentInvoice: invoicePrint,
          selectedProducts: listProducts,
          additionalProducts: listAddProducts,
        ),
      ),
    );
  }

  bool _validateEnableSave() {
    if (widget.editInvoice != null) {
      //valido que la factura no tenga mas de 3 dias para permitir agregar un incidente
      String _incidence = widget.editInvoice.incidence ?? '';
      var dateInvoice = widget.editInvoice.creationDate;
      var daysAfterInvoice = dateInvoice.toDate().add(Duration(days: 3));
      int _validDate = DateTime.now().compareTo(daysAfterInvoice);
      if (_incidence.isEmpty && _validDate < 0) {
        _enablePerIncidence = true;
      }
    }

    return (_editOperator || _editForm || _enablePerIncidence) ? true : false;
  }

  Future<bool> _alertBackButton() {
    Alert(
      context: context,
      type: AlertType.info,
      title: 'Esta seguro que desea salir de la factura !',
      style: MessagesUtils.alertStyle,
      buttons: [
        DialogButton(
          color: Theme.of(context).accentColor,
          child: Text(
            'ACEPTAR',
            style: Theme.of(context).textTheme.button,
          ),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.pop(context);
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
            return false;
          },
        ),
      ],
    ).show();
    //return false;
    //return showDialog(context: context, builder:(context) => AlertDialog(title: Text('back pressed'),));
  }
}
