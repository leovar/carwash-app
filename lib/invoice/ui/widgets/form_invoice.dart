import 'dart:io';

import 'package:car_wash_app/commission/bloc/bloc_commission.dart';
import 'package:car_wash_app/commission/model/commission.dart';
import 'package:car_wash_app/customer/bloc/bloc_customer.dart';
import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/additional_product.dart';
import 'package:car_wash_app/invoice/model/configuration.dart';
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
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/sysUser.dart';
import 'package:car_wash_app/vehicle/bloc/bloc_vehicle.dart';
import 'package:car_wash_app/widgets/gradient_back.dart';
import 'package:car_wash_app/widgets/info_header_container.dart';
import 'package:car_wash_app/widgets/keys.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:popup_menu/popup_menu.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../vehicle/model/vehicle.dart';
import '../../model/header_services.dart';
import 'carousel_cars_widget.dart';
import 'fields_invoice.dart';
import 'fields_menu_invoice.dart';
import 'fields_operators.dart';

class FormInvoice extends StatefulWidget {
  final Invoice? editInvoice;

  FormInvoice( this.editInvoice);

  @override
  State<StatefulWidget> createState() => _FormInvoice();
}

class _FormInvoice extends State<FormInvoice> {
  late BlocInvoice _blocInvoice;
  final _customerBloc = BlocCustomer();
  final _blocVehicle = BlocVehicle();
  final _userBloc = UserBloc();
  final _locationBloc = BlocLocation();
  BlocCommission _blocCommission = BlocCommission();
  late bool _enableForm;
  bool _editForm = true;
  bool _enablePerIncidence = false;
  bool _closedInvoice = false;

  ///global variables
  //Esta variable _scaffoldKey se usa para poder abrir el drawer desde un boton diferente al que se coloca por defecto en el AppBar
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  GlobalKey btnAddImage = GlobalKey();
  List<String> imageList = [];
  String _tagSpecialService = 'Especial';
  String _tagSimpleService = 'Sencillo';
  bool _sendEmail = false;
  bool _approveDataProcessing = false;
  Uint8List? _imageFirmInMemory;
  String _placa = '';
  List<HeaderServices> vehicleTypeList = [];
  late HeaderServices vehicleTypeSelected;
  final String cameraTag = "Camara";
  final String galleryTag = "Galeria";
  String _selectSourceImagePicker = "Camara";
  final picker = ImagePicker();
  File? _imageSelect;
  late FocusNode _clientFocusNode;
  late DocumentReference _locationReference;
  late String _locationName;
  late String _idLocation;
  late String _initConsecLocation;
  late String _finalConsecLocation;
  String _selectBrand = '';
  String _selectedBrandReference = '';
  String _selectColor = '';
  String _selectTypeSex = '';
  String _selectedPaymentMethod = '';

  final _textPlaca = TextEditingController();
  final _textClient = TextEditingController();
  final _textEmail = TextEditingController();
  final _textPhoneNumber = TextEditingController();
  final _textNeighborhood = TextEditingController();
  final _textBirthDate = TextEditingController();
  final _textTimeDelivery = TextEditingController();
  final _textObservation = TextEditingController();
  final _textIncidence = TextEditingController();
  String _selectCoordinator = "";
  List<Product> _listProduct = <Product>[];
  List<AdditionalProduct> _listAdditionalProducts = <AdditionalProduct>[];
  bool _validatePlaca = false;
  Customer _customer = new Customer();
  DocumentReference _vehicleReference = FirebaseFirestore.instance.collection('vehicles').doc('defaultDocId') ;
  int _countOperators = 0;
  int _listCoordinatorsCount = 0;
  int _countBrands = 0;
  int _countBrandReferences = 0;
  int _countPaymentMethods = 0;
  int _countColors = 0;
  late SysUser _currentUser;
  bool _isUserAdmin = false;
  bool _canceledInvoice = false;
  Configuration _config = Configuration();
  List<SysUser> _listOperators = <SysUser>[];

  @override
  void initState() {
    super.initState();
    getPreferences();
    _enableForm = false;
    _clientFocusNode = FocusNode();
    _countOperators = 0;
    _listCoordinatorsCount = 0;
    _countBrands = 0;
    _countColors = 0;
    _idLocation = '';
    //_imageFirmInMemory = Uint8List(0);
    //TODO traer estos datos desde la base de datos y cargarlos en un widget aparte con un stream
    vehicleTypeList.add(
      HeaderServices(
        false,
        "Auto",
        1,
        38,
        "assets/images/icon_car_admin.png",
        "assets/images/icon_car.png",
      ),
    );
    vehicleTypeList.add(
      HeaderServices(
        false,
        "Camioneta",
        2,
        37,
        'assets/images/icon_suv_car_admin.png',
        "assets/images/icon_suv_car.png",
      ),
    );
    vehicleTypeList.add(
      HeaderServices(
        false,
        "Moto",
        3,
        34,
        "assets/images/icon_motorcycle_admin.png",
        "assets/images/icon_motorcycle.png",
      ),
    );
    vehicleTypeList.add(
      HeaderServices(
        false,
        "Bicicleta",
        4,
        34,
        "assets/images/icon_motorcycle_admin.png",
        "assets/images/icon_motorcycle.png",
      ),
    );
    vehicleTypeList[0].isSelected = true;
    vehicleTypeSelected = vehicleTypeList[0];
    if (widget.editInvoice != null) {
      _editInvoice(widget.editInvoice);
      _editForm = false;
    }
    _userBloc.getCurrentUser().then((SysUser? user) {
      _currentUser = user!;
      if (user.isAdministrator??false) {
        setState(() {
          _isUserAdmin = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _clientFocusNode.dispose();
    _blocInvoice.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    this._blocInvoice = BlocProvider.of<BlocInvoice>(context);

    if (_imageSelect != null) {
      if (_imageSelect!.path.contains('imageFirm')) {
        var _imagePath = _imageSelect!.path;
        var _oldImageFirmPath =
        imageList.where((e) => e.contains('imageFirm')).toList();
        _deleteImageList(
          _oldImageFirmPath.length > 0 ? _oldImageFirmPath[0].toString() : '',
        );
        imageList.add(_imagePath);
      } else {
        if (!imageList.contains(_imageSelect!.path)) {
          imageList.add(_imageSelect!.path);
        }
      }
    }

    //TODO Validar si es necesario asignarle un valor null a esta variable o funciona bien sin asignarle un null
    //_imageSelect = null;
    return WillPopScope(
      child: Stack(children: <Widget>[GradientBack(), bodyContainer()]),
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
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 5.0)],
        ),
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
                      vehicleTypeList.forEach(
                        (element) => element.isSelected = false,
                      );
                      vehicleTypeList[index].isSelected = true;
                      vehicleTypeSelected = vehicleTypeList[index];
                      _listAdditionalProducts = <AdditionalProduct>[];
                      _listProduct = <Product>[];
                      _listOperators = <SysUser>[];
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
          : 'Factura Nro ${widget.editInvoice?.consecutive??''}',
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
        padding: EdgeInsets.only(right: 15, left: 15, top: 15, bottom: 15),
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
                cbHandlerSendEmail: _setHandlerSendEmailInvoice,
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
                listCountCoordinators: _listCoordinatorsCount,
                listCountBrands: _countBrands,
                listCountColors: _countColors,
                listCountBrandReference: _countBrandReferences,
                listCountPaymentMethods: _countPaymentMethods,
                cbHandlerCoordinator: _setHandlerUserCoordinator,
                cbHandlerVehicleBrand: _setHandlerVehicleBrand,
                cbHandlerVehicleBrandReference: _setHandlerBrandReferences,
                cbHandlerVehicleColor: _setHandlerVehicleColor,
                cbHandlerTypeSex: _setHandlerTypeSex,
                cbHandlerPaymentMethod: _setHandlerPaymentMethod,
                idLocation: _idLocation,
                selectedCoordinator: _selectCoordinator,
                selectedVehicleBrand: _selectBrand,
                selectVehicleBrandReference: _selectedBrandReference,
                selectedVehicleColor: _selectColor,
                selectedTypeSex: _selectTypeSex,
                selectedPaymentMethod: _selectedPaymentMethod,
                uidVehicleType: vehicleTypeSelected.uid,
                enableForm: _enableForm,
              ),
              SizedBox(height: 9),
              TextFieldInput(
                textController: _textObservation,
                labelText: 'Observaciones',
                inputType: TextInputType.multiline,
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
                    enable: _enablePerIncidence,
                  ),
                ),
              ),
              SizedBox(height: 9),
              FieldsOperators(
                callbackOperatorsList: _setOperatorsDb,
                operatorsListCallback: _listOperators,
                enableForm: _enableForm,
                selectedOperatorsCount:
                    _listOperators.where((f) => (f.isSelected??false)).toList().length,
                editForm: _editForm,
                closedInvoice: _closedInvoice,
                idLocation: _idLocation,
                invoice: widget.editInvoice,
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
                    _listProduct.where((f) => (f.isSelected??false)).toList().length +
                        _listAdditionalProducts.length,
                editForm: _editForm,
                invoice: widget.editInvoice,
              ),
              SizedBox(height: 9),
              Visibility(visible: _editForm, child: _showDraw()),
              Visibility(
                visible: _validateEnableSave(),
                child: _saveInvoiceButton(),
              ),
              Visibility(
                visible: (!_editForm && !_canceledInvoice),
                child: _rePrintInvoice(),
              ),
              Visibility(
                visible: (!_editForm && _isUserAdmin && !_canceledInvoice),
                child: _cancelInvoice(),
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
            child: Icon(Icons.add, color: Colors.black, size: 30),
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
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              backgroundColor: Color(0xFF59B258),
            ),
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
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
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
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
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
              _printInvoice(
                widget.editInvoice,
                _listProduct.where((f) => (f.isSelected??false)).toList(),
                _listAdditionalProducts,
                _textEmail.text.trim(),
              );
                        },
          ),
        ),
      ),
    );
  }

  Widget _cancelInvoice() {
    return Container(
      height: 80,
      child: Align(
        alignment: Alignment.center,
        child: ButtonTheme(
          minWidth: 230.0,
          height: 45,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              backgroundColor: Theme.of(context).colorScheme.secondary,
            ),
            child: Text(
              "CANCELAR FACTURA",
              style: TextStyle(
                fontFamily: "Lato",
                decoration: TextDecoration.none,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 19,
              ),
            ),
            onPressed: () {
              Alert(
                context: context,
                type: AlertType.warning,
                title: 'Esta seguro de anular la factura?',
                style: MessagesUtils.alertStyle,
                buttons: [
                  DialogButton(
                    color: Theme.of(context).colorScheme.secondary,
                    child: Text(
                      'CANCELAR',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      setState(() {});
                    },
                  ),
                  DialogButton(
                    color: Theme.of(context).colorScheme.secondary,
                    child: Text(
                      'ACEPTAR',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    onPressed: () {
                      _canceledInvoice = true;
                      Navigator.of(context).pop();
                      _cancelInvoiceFunction();
                    },
                  ),
                ],
              ).show();
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
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PrintInvoice()),
            );
          },
        ),
      ),
    );
  }

  ///  Functions  ////////////////////////////////////////////////

  ///Image Functions
  void _menuSourceAddImage() {
    PopupMenu menu = PopupMenu(
      context: context,
      config: MenuConfig(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        lineColor: Theme.of(context).colorScheme.secondary,
        maxColumn: 1,
      ),
      items: [
        MenuItem(
          title: cameraTag,
          textStyle: TextStyle(color: Colors.white),
          image: Icon(Icons.camera_alt, color: Colors.white),
        ),
        MenuItem(
          title: galleryTag,
          textStyle: TextStyle(color: Colors.white),
          image: Icon(Icons.image, color: Colors.white),
        ),
      ],
      onClickMenu: _onClickMenuImageSelected,
    );
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
    final ImagePicker picker = ImagePicker();
    XFile ?imageCapture = await picker
        .pickImage(
          source: _selectSourceImagePicker == cameraTag
              ? ImageSource.camera
              : ImageSource.gallery,
          imageQuality: 80,
        )
        .catchError((onError) => print(onError));

    if (imageCapture != null) {
      // Esta parte de compress se coloca por que no va con crop, si fuera con crop esta parte ya esta en el crop
      final dir = await path_provider.getTemporaryDirectory();
      final targetPath = dir.absolute.path +
          "/${imageCapture.path.substring(imageCapture.path.length - 10, imageCapture.path.length)}"; //dir.absolute.path + "/temp${imageList.length}.jpg";
      XFile? fileCompress = await FlutterImageCompress.compressAndGetFile(
        imageCapture.path,
        targetPath,
        quality: 50,
        autoCorrectionAngle: true,
        format: CompressFormat.jpeg,
      );
      setState(() {
        _imageSelect = fileCompress != null ? File(fileCompress.path) : File(imageCapture.path);
        // el crop es comentado por que el cliente quiere que asi como se tome la foto quede.
        //_cropImage(imageCapture);
      });
    }
  }

  Future<void> _cropImage(File imageCapture) async {
    CroppedFile? _croppedFile = await ImageCropper().cropImage(
      sourcePath: imageCapture.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 40,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.white,
          toolbarWidgetColor: Theme.of(context).primaryColor,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        IOSUiSettings(
          title: 'Cropper',
          minimumAspectRatio: 1.0,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio5x3,
            CropAspectRatioPreset.ratio5x4,
            CropAspectRatioPreset.ratio7x5,
            CropAspectRatioPreset.ratio16x9,
          ],
        ),
        WebUiSettings(
          context: context,
          presentStyle: WebPresentStyle.dialog,
          size: const CropperSize(
            width: 520,
            height: 520,
          ),
        ),
      ],
    );

    if (_croppedFile != null) {
      XFile? compressedFile = await FlutterImageCompress.compressAndGetFile(
        _croppedFile.path,
        _croppedFile.path,
        quality: 40,
      );

      File fileCompress = compressedFile != null ? File(compressedFile.path) : File(_croppedFile.path);

      setState(() {
        _imageSelect = fileCompress;
      });
    }
  }

  ///Functions Select Menu
  void _setHandlerUserCoordinator(
    String selectCoordinator,
    int countList,
    int operationType,
  ) {
    if (operationType == 1) {
      _selectCoordinator = selectCoordinator;
    } else {
      _listCoordinatorsCount = countList;
    }
  }

  //operationType 1=setBrand, 2= setCountBrands
  void _setHandlerVehicleBrand(
    String brand,
    int countBrands,
    int operationType,
  ) {
    if (operationType == 1) {
      _selectBrand = brand;
    } else {
      _countBrands = countBrands;
    }
  }

  //operationType 1=setBrand, 2= setCountBrands
  void _setHandlerBrandReferences(
    String brandReference,
    int countBrands,
    int operationType,
  ) {
    if (operationType == 1) {
      _selectedBrandReference = brandReference;
    } else {
      _countBrandReferences = countBrands;
    }
  }

  //operationType 1=setColor, 2= setCountColors
  void _setHandlerVehicleColor(
    String vehicleColor,
    int countColors,
    int operationType,
  ) {
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

  //Payment Methods
  void _setHandlerPaymentMethod(
    String paymentMethod,
    int countPayment,
    int operationType,
  ) {
    if (operationType == 1) {
      _selectedPaymentMethod = paymentMethod;
    } else {
      _countPaymentMethods = countPayment;
    }
  }

  void _setHandlerSendEmailInvoice(bool value) {
    _sendEmail = value;
  }

  ///Functions Image Firma
  void _callBackApproveDataprocessing(bool value) {
    _approveDataProcessing = value;
  }

  // la variable _imageFirmInMemory ya no se usa por que la firma se esta agregarndo dentro de la lista de imagenes.
  void _callBackChargeFirm(Uint8List imageFirm) async {
    _imageFirmInMemory = imageFirm;
    String formattedDate = DateFormat('kk_mm_ss').format(DateTime.now());
    final dir = await path_provider.getTemporaryDirectory();
    final file = await new File(
      '${dir.absolute.path}/imageFirm$formattedDate.jpg',
    ).create();
    file.writeAsBytesSync(imageFirm);
    print(file.path);
    setState(() {
      _imageSelect = file;
    });
  }

  ///Functions Services or Products
  void _setProductsDb(List<Product> productListSelected) {
    setState(() {
      _listProduct = productListSelected;
    });
  }

  void _setAdditionalProducts(List<AdditionalProduct> additionalProductList) {
    setState(() {
      _listAdditionalProducts = additionalProductList;
    });
  }

  ///Functions Operator Users List
  void _setOperatorsDb(List<SysUser> operatorsListSelected) async {
    int _countOperators = 0;
    List<SysUser> _operatorsToSave = [];
    List<SysUser> _selectedOperators =
        operatorsListSelected.where((u) => (u.isSelected??false)).toList();
    _selectedOperators.forEach((user) {
      var operatorSave = SysUser.copyUserOperatorToSaveInvoice(
        id: user.id,
        name: user.name,
        operatorCommission: ((widget.editInvoice?.totalCommission ?? 0) /
                _selectedOperators.length)
            .ceilToDouble(),
      );
      _operatorsToSave.add(operatorSave);
    });
    _countOperators = _selectedOperators.length;
    Invoice invoice = Invoice.copyWith(
      origin: widget.editInvoice ?? new Invoice(),
      listOperators: _operatorsToSave,
      countOperators: _countOperators,
    );
    await _blocInvoice.saveInvoice(invoice);
    setState(() {
      _listOperators = operatorsListSelected;
    });
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
        _getVehicleInfo(_placa);
      } else {
        setState(() {
          _cleanTextFields();
          //_validatePlaca = true;
          _enableForm = false;
        });
      }
    }
  }

  Future<void> _getVehicleInfo (String _placa) async {
    try {
      // Get Vehicle Reference
      DocumentReference? _vehicleRef = await _blocVehicle.getVehicleReferenceByPlaca(_placa);
      if (_vehicleRef != null) {
        _vehicleReference = _vehicleRef;

        // Get Vehicle Data
        var vehicle = await _blocVehicle.getVehicleById(_vehicleReference.id);
        _selectBrand = vehicle.brand??'';
        _selectColor = vehicle.color??'';
        _selectedBrandReference = vehicle.brandReference??'';

        HeaderServices vehicleTypeFind = vehicleTypeList.firstWhere((f) => f.text == vehicle.vehicleType);

        vehicleTypeSelected = vehicleTypeFind;
        setState(() {
          for (var element in vehicleTypeList) {
            element.isSelected = false;
          }
          vehicleTypeList[vehicleTypeList.indexOf(vehicleTypeSelected)]
              .isSelected = true;
        });
        // Validate services from the last 2 months
        _getInvoicesForPlaca(_placa);

        // Validate if Customer exists for this vehicle
        _customer = await _customerBloc.getCustomerByVehicle(_vehicleReference);

        setState(() {
          _textClient.text = _customer.name??'';
          _textEmail.text = _customer.email??'';
          _textPhoneNumber.text = _customer.phoneNumber??'';
          _textNeighborhood.text = _customer.neighborhood??'';
          _textBirthDate.text = _customer.birthDate??'';
          _selectTypeSex = _customer.typeSex??'';
        });
      } else {
        _selectBrand = '';
        _selectColor = '';
        _selectedBrandReference = '';
        setState(() {});
      }
    } catch (e) {
      print("Error fetching vehicle and customer data: $e");
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
    setState(() {
      _locationName = pref.getString(Keys.locationName) ?? '';
      _locationName = pref.getString(Keys.locationName) ?? '';
      _initConsecLocation = pref.getString(Keys.locationInitCount) ?? '';
      _finalConsecLocation = pref.getString(Keys.locationFinalCount) ?? '';
      _idLocation = pref.getString(Keys.idLocation) ?? '';
    });
    _locationReference = await _locationBloc.getLocationReference(_idLocation);
    _blocInvoice.getConfigurationObject().then((value) => _config = value);
  }

  // Get last invoices per vehicle
  void _getInvoicesForPlaca(String placa) async {
    try {
      List<Invoice> listInvoicesByVehicle = await _blocInvoice.getListInvoicesByVehicle(placa) ?? [];
      if (listInvoicesByVehicle.length > 0) {
        final dataList = listInvoicesByVehicle
            .map(
              (vehicleInvoice) => InvoiceHistoryList(
                vehicleInvoice.creationDate!,
                vehicleInvoice.consecutive?.toString() ?? '',
                (vehicleInvoice.invoiceProducts?.isNotEmpty ?? false)
                    ? vehicleInvoice.invoiceProducts!.first.productName ?? ''
                    : '',
                vehicleInvoice.totalPrice ?? 0,
              ),
            )
            .toList();

        Alert(
          context: context,
          title: 'Historia',
          style: MessagesUtils.alertStyle,
          content: InfoLastServicesByVehicle(listHistoryInvoices: dataList),
          buttons: [
            DialogButton(
              color: Theme.of(context).colorScheme.secondary,
              child: Text('ACEPTAR', style: Theme.of(context).textTheme.labelLarge),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
              },
            ),
          ],
        ).show();
      }
    } catch (e) {
      print(e);
    }
  }

  ///Function calculate commission per product
  double _calculateCommissionProduct(
    List<Commission> commissionsList,
    String prodType,
    double prodPrice,
    int vehicleType,
  ) {
    final commissionProd = commissionsList.firstWhere(
      (c) => c.productType == prodType && c.uidVehicleType == vehicleType,
      orElse: () => new Commission(),
    );
    bool isNormal = false;
    double calculateComm = 0;
    if ((commissionProd.commissionThreshold??0) > 0) {
      if (prodPrice <= (commissionProd.commissionThreshold??0)) {
        if (commissionProd.calculatePerCount??false) {
          calculateComm = commissionProd.isValue??false
              ? commissionProd.valueBeforeThreshold??0
              : (commissionProd.valueBeforeThreshold??0) / 100;
        } else {
          calculateComm = commissionProd.isValue??false
              ? prodPrice * (commissionProd.valueBeforeThreshold??0)
              : (prodPrice * (commissionProd.valueBeforeThreshold??0)) / 100;
        }
      } else {
        isNormal = true;
      }
    } else {
      isNormal = true;
    }
    if (isNormal) {
      if (commissionProd.calculatePerCount??false) {
        calculateComm = (commissionProd.isValue??false)
            ? commissionProd.value??0
            : (commissionProd.value??0) / 100;
      } else {
        calculateComm = commissionProd.isValue??false
            ? prodPrice * (commissionProd.value??0)
            : (prodPrice * (commissionProd.value??0)) / 100;
      }
    }
      return calculateComm;
  }

  ///Functions Save Invoice
  void _saveInvoice() async {
    bool _haveServiceSpecial = false;
    //validate internet connection if have images
    if (imageList.length > 0) {
      List<ConnectivityResult> connectivityResult = await (Connectivity().checkConnectivity());
      var connectionMobile = connectivityResult.contains(ConnectivityResult.mobile);
      var connectionWifi = connectivityResult.contains(ConnectivityResult.wifi);
      if (!connectionMobile && !connectionWifi) {
        MessagesUtils.showAlert(
          context: context,
          title:
              'No tiene conexión a internet! no se pueden guardar las imagenes',
        ).show();
        return;
      }
    }

    String validateMessage = _validateFields();
    if (validateMessage.isEmpty) {
      //Open message Saving
      MessagesUtils.showAlertWithLoading(
        context: context,
        title: 'Guardando',
      ).show();

      try {
        DocumentReference _vehicleTypeRef; //esta referencia debe traerse de la bd, en el momento se construye en la app
        DocumentReference _customerReference;
        DocumentReference? _coordinatorReference;
        double _total = 0;
        double _iva = 0;
        double _subTotal = 0;
        int _countProducts = 0;
        int _countAdditionalProducts = 0;
        int _servicesWashingTime = 0;
        int _countOperators = 0;
        double _totalCommission = 0;

        //Get Current user reference
        DocumentReference _userRef = await _userBloc.getCurrentUserReference();

        //Get Coordinator reference
        if (_selectCoordinator.isNotEmpty) {
          _coordinatorReference = await _userBloc.getUserReferenceByUserName(
            _selectCoordinator,
          );
        }

        //Get Vehicle reference, save if not exist
        if (_vehicleReference.id == 'defaultDocId' || _vehicleReference.id == '') {
          Vehicle updateVehicle = Vehicle(
            brand: _selectBrand,
            model: '',
            placa: _textPlaca.text.trim(),
            color: _selectColor,
            vehicleType: vehicleTypeSelected.text,
            //_vehicleTypeRef,
            creationDate: Timestamp.now(),
            brandReference: _selectedBrandReference,
          );
          DocumentReference vehicleRef =
          await _blocVehicle.updateVehicle(updateVehicle);
          _vehicleReference = vehicleRef;
        }

        //Get Customer reference or create customer or update customer
        if (_customer.id == null || _customer.id == '') {
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
          if (!(_customer.vehicles?.contains(_vehicleReference)??false)) {
            _customer.vehicles?.add(_vehicleReference);
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
          _customerReference = await _customerBloc.updateCustomer(
            customerUpdate,
          );
        }
      
        //Obtiene los valores de los productos para calcular el subtotal, iva y total
        _listProduct.forEach((product) {
          //If at least only one services is special
          if (product.productType == _tagSpecialService)
            _haveServiceSpecial = true;

          // Get pricing information
          if (product.isSelected??false) {
            int _subT =
                (((product.price??0) * 100) / (100 + (product.ivaPercent??0))).round();
            int _ivaProd = ((_subT * (product.ivaPercent??0)) / 100).round();
            // se comenta por que por los decimales la suma de subtotal e iva no siempre da el total, por lo cual se seguira guardando el subtotal como una resta del total menos el iva
            _subTotal = _subTotal + ((product.price??0) - _ivaProd); //_subT
            _iva = _iva + _ivaProd;
            _total = _total + (product.price??0);
            _servicesWashingTime = _servicesWashingTime + (product.serviceTime??0);
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
          _servicesWashingTime = _servicesWashingTime + addProduct.serviceTime;
        });

        //Save products list
        List<Commission> commissionsList =
            await _blocCommission.getAllCommissions();
        List<Product> _selectedProducts =
            _listProduct.where((f) => (f.isSelected??false)).toList();
        List<Product> _productToSave = [];
        if (_selectedProducts.length > 0) {
          _selectedProducts.forEach((product) {
            if (product.newProduct ?? true) {
              // TODO calcular comisión por producto en este punto antes de guardarlo
              double commission = _calculateCommissionProduct(
                commissionsList,
                product.productType??'',
                product.price??0,
                vehicleTypeSelected.uid,
              );
              var prodSave = Product.copyProductToSaveInvoice(
                id: product.id,
                productName: product.productName,
                price: product.price,
                ivaPercent: product.ivaPercent,
                isAdditional: false,
                productType: product.productType,
                serviceTime: product.serviceTime,
                commission: commission,
              );
              _totalCommission = _totalCommission + commission;
              _productToSave.add(prodSave);
            }
          });
        }
        if (_listAdditionalProducts.length > 0) {
          _listAdditionalProducts.forEach((addProduct) {
            // TODO calcular comisión por producto en este punto antes de guardarlo
            double commission = _calculateCommissionProduct(
              commissionsList,
              addProduct.productType,
              double.parse(addProduct.productValue),
              vehicleTypeSelected.uid,
            );
            var prodSave = Product.copyProductToSaveInvoice(
              id: null,
              productName: addProduct.productName,
              price: double.parse(addProduct.productValue),
              ivaPercent: addProduct.ivaPercent,
              isAdditional: true,
              productType: addProduct.productType,
              commission: commission,
            );
            _totalCommission = _totalCommission + commission;
            _productToSave.add(prodSave);
          });
        }

        //Save user operators
        List<SysUser> _operatorsToSave = [];
        List<SysUser> _selectedOperators =
            _listOperators.where((u) => (u.isSelected??false)).toList();
        if (_selectedOperators.length > 0) {
          _selectedOperators.forEach((user) {
            var operatorSave = SysUser.copyUserOperatorToSaveInvoice(
              id: user.id,
              name: user.name,
              operatorCommission:
                  (_totalCommission / _selectedOperators.length).ceilToDouble(),
            );
            _operatorsToSave.add(operatorSave);
          });
        }

        //Get count operators
        _countOperators =
            _listOperators.where((u) => (u.isSelected??false)).toList().length;

        //Get count products
        _countProducts =
            _listProduct.where((f) => (f.isSelected??false)).toList().length;
        _countAdditionalProducts = _listAdditionalProducts.length;

        //Get Consecutive
        int _consecutive = await _blocInvoice.getLastConsecutiveByLocation(
          _locationReference,
        );
        if (_consecutive == 0) {
          _consecutive = int.parse(_initConsecLocation);
        } else {
          _consecutive++;
        }

        final _invoice = Invoice(
          id: widget.editInvoice != null ? widget.editInvoice?.id : null,
          consecutive: widget.editInvoice != null
              ? widget.editInvoice?.consecutive
              : _consecutive,
          customer: _customerReference,
          phoneNumber: _textPhoneNumber.text.trim(),
          vehicle: _vehicleReference,
          placa: _textPlaca.text.trim(),
          uidVehicleType: vehicleTypeSelected.uid,
          location: widget.editInvoice != null
              ? widget.editInvoice?.location
              : _locationReference,
          locationName: widget.editInvoice != null
              ? widget.editInvoice?.locationName
              : _locationName,
          totalPrice: widget.editInvoice != null
              ? widget.editInvoice?.totalPrice
              : _total,
          subtotal: widget.editInvoice != null
              ? widget.editInvoice?.subtotal
              : _subTotal,
          iva: widget.editInvoice != null ? widget.editInvoice?.iva : _iva,
          userOwner: widget.editInvoice != null
              ? widget.editInvoice?.userOwner
              : _userRef,
          userCoordinator: _coordinatorReference,
          userCoordinatorName: _selectCoordinator,
          creationDate: widget.editInvoice != null
              ? widget.editInvoice?.creationDate
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
          haveSpecialService: widget.editInvoice != null
              ? widget.editInvoice?.haveSpecialService
              : _haveServiceSpecial,
          countProducts: _countProducts,
          countAdditionalProducts: _countAdditionalProducts,
          sendEmailInvoice: _sendEmail,
          invoiceProducts: widget.editInvoice != null
              ? widget.editInvoice?.invoiceProducts
              : _productToSave,
          cancelledInvoice: widget.editInvoice != null
              ? widget.editInvoice?.cancelledInvoice
              : _canceledInvoice,
          paymentMethod: _selectedPaymentMethod,
          closedDate:
              widget.editInvoice != null ? widget.editInvoice?.closedDate : null,
          invoiceClosed: widget.editInvoice != null
              ? widget.editInvoice?.invoiceClosed
              : false,
          endWash:
              widget.editInvoice != null ? widget.editInvoice?.endWash : false,
          dateEndWash: widget.editInvoice != null
              ? widget.editInvoice?.dateEndWash
              : null,
          startWashing: widget.editInvoice != null
              ? widget.editInvoice?.startWashing
              : false,
          dateStartWashing: widget.editInvoice != null
              ? widget.editInvoice?.dateStartWashing
              : null,
          washingTime: widget.editInvoice != null
              ? widget.editInvoice?.washingTime
              : null,
          washingCell: widget.editInvoice?.washingCell,
          countWashingWorkers: widget.editInvoice != null
              ? widget.editInvoice?.countWashingWorkers
              : null,
          washingServicesTime: _servicesWashingTime,
          operatorUsers: _operatorsToSave,
          countOperators: _countOperators,
          totalCommission: widget.editInvoice != null
              ? widget.editInvoice?.totalCommission
              : _totalCommission,
        );
        DocumentReference invoiceReference = await _blocInvoice.saveInvoice(
          _invoice,
        );
        String invoiceId = invoiceReference.id;
        Invoice _currentInvoiceSaved = await _blocInvoice.getInvoiceById(
          invoiceId,
        );

        //Close screen
        Navigator.pop(context); //Close popUp Save
        Navigator.pop(context);

        if (widget.editInvoice == null) {
          _printInvoice(_currentInvoiceSaved, _selectedProducts,
              _listAdditionalProducts, _textEmail.text.trim());
        }
      } on PlatformException catch (e) {
        print('$e');
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: "Error guardando la factura: $e",
          toastLength: Toast.LENGTH_LONG,
        );
      } catch (error) {
        print('$error');
        Navigator.pop(context);
        Fluttertoast.showToast(
          msg: "Error guardando la factura: $error",
          toastLength: Toast.LENGTH_LONG,
        );
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
        _listProduct.where((f) => (f.isSelected??false)).toList();
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
  void _editInvoice(Invoice? invoiceToEdit) async {
    if (invoiceToEdit != null) {
      _textPlaca.text = invoiceToEdit.placa??'';
      _selectCoordinator = invoiceToEdit.userCoordinatorName??'';
      _selectBrand = invoiceToEdit.vehicleBrand ?? '';
      _selectedBrandReference = invoiceToEdit.brandReference ?? '';
      _selectColor = invoiceToEdit.vehicleColor ?? '';
      _approveDataProcessing = invoiceToEdit.approveDataProcessing ?? false;
      _textTimeDelivery.text = invoiceToEdit.timeDelivery ?? '';
      _textObservation.text = invoiceToEdit.observation ?? '';
      _textIncidence.text = invoiceToEdit.incidence ?? '';
      _selectedPaymentMethod = invoiceToEdit.paymentMethod ?? '';
      _closedInvoice = invoiceToEdit.invoiceClosed ?? false;
      _sendEmail = invoiceToEdit.sendEmailInvoice ?? false;
      _canceledInvoice = invoiceToEdit.cancelledInvoice ?? false;

      //get vehicle reference
      DocumentReference? _vehicleRef = await _blocVehicle.getVehicleReferenceByPlaca(invoiceToEdit.placa??'');
      if (_vehicleRef != null) {
        _vehicleReference = _vehicleRef;
      }
      //get customer information
      _customer = await _customerBloc.getCustomerByIdCustomer(
        invoiceToEdit.customer?.id??'',
      );

      _textClient.text = _customer.name ?? '';
      _textEmail.text = _customer.email ?? '';
      _textPhoneNumber.text = _customer.phoneNumber ?? '';
      _textBirthDate.text = _customer.birthDate ?? '';
      _textNeighborhood.text = _customer.neighborhood ?? '';
      _selectTypeSex = _customer.typeSex ?? '';
      vehicleTypeList.forEach((element) => element.isSelected = false);
      vehicleTypeSelected = vehicleTypeList.firstWhere(
            (f) => f.uid == invoiceToEdit.uidVehicleType,
      );
      setState(() {
        vehicleTypeList[vehicleTypeList.indexOf(vehicleTypeSelected)].isSelected =
        true;
      });
      List<Product> listProducts = invoiceToEdit.invoiceProducts ?? [];
      List<Product> productEditList = <Product>[];
      listProducts.forEach((prodSelected) {
        if (!(prodSelected.isAdditional??false)) {
          prodSelected.newProduct = false;
          productEditList.add(prodSelected);
        } else {
          AdditionalProduct addProd = AdditionalProduct(
            prodSelected.productName ?? '',
            prodSelected.price.toString(),
            prodSelected.ivaPercent ?? 0,
            false,
            prodSelected.productType ?? '',
            prodSelected.serviceTime ?? 0,
          );
          _listAdditionalProducts.add(addProd);
        }
      });
      setState(() {
        _listProduct = productEditList;
        _listOperators = invoiceToEdit.operatorUsers ?? [];
      });
      List<String> imagesList = await _blocInvoice.getInvoiceImages(
        invoiceToEdit.id??'',
      );
      setState(() {
        imageList = imagesList;
      });
    }
  }

  void _cancelInvoiceFunction() async {
    if (widget.editInvoice != null) {
      MessagesUtils.showAlertWithLoading(
        context: context,
        title: 'Guardando',
      ).show();
      Invoice invoiceCopy = Invoice.copyWith(
        origin: widget.editInvoice?? new Invoice(),
        cancelledInvoice: _canceledInvoice,
      );
      _blocInvoice.saveInvoice(invoiceCopy);
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  void _printInvoice(
    Invoice? invoicePrint,
    List<Product> listProducts,
    List<AdditionalProduct> listAddProducts,
    String customerEmail,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrintInvoicePage(
          currentInvoice: invoicePrint,
          selectedProducts: listProducts,
          additionalProducts: listAddProducts,
          customerEmail: customerEmail,
          configuration: _config,
        ),
      ),
    );
  }

  bool _validateEnableSave() {
    //valido que la factura no tenga mas de 3 dias para permitir agregar un incidente
    String _incidence = widget.editInvoice?.incidence ?? '';
    var dateInvoice = widget.editInvoice?.creationDate ?? Timestamp.now();
    var daysAfterInvoice = dateInvoice.toDate().add(Duration(days: 3));
    int _validDate = DateTime.now().compareTo(daysAfterInvoice!);
    if (_incidence.isEmpty && _validDate < 0) {
      _enablePerIncidence = true;
    }
  
    return (_editForm || _enablePerIncidence) ? true : false;
  }

  Future<bool> _alertBackButton() async {
    bool exitConfirmed = false; // Default value

    await Alert(
      context: context,
      type: AlertType.info,
      title: 'Esta seguro que desea salir de la factura !',
      style: MessagesUtils.alertStyle,
      buttons: [
        DialogButton(
          color: Theme.of(context).colorScheme.secondary,
          child: Text('ACEPTAR', style: Theme.of(context).textTheme.labelLarge),
          onPressed: () {
            exitConfirmed = true;
            Navigator.of(context).pop();
            Navigator.pop(context);
          },
        ),
        DialogButton(
          color: Theme.of(context).colorScheme.secondary,
          child: Text('CANCELAR', style: Theme.of(context).textTheme.labelLarge),
          onPressed: () {
            exitConfirmed = false;
            Navigator.of(context).pop();
          },
        ),
      ],
    ).show();

    return exitConfirmed;
    //return showDialog(context: context, builder:(context) => AlertDialog(title: Text('back pressed'),));
  }
}
