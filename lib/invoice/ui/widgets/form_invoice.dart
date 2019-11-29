import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:car_wash_app/customer/bloc/bloc_customer.dart';
import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/additional_product.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
import 'package:car_wash_app/invoice/ui/screens/draw_page.dart';
import 'package:car_wash_app/invoice/ui/widgets/fields_products.dart';
import 'package:car_wash_app/invoice/ui/widgets/radio_item.dart';
import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/product/bloc/product_bloc.dart';
import 'package:car_wash_app/product/model/product.dart';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/vehicle/bloc/bloc_vehicle.dart';
import 'package:car_wash_app/vehicle/model/vehicle.dart';
import 'package:car_wash_app/widgets/gradient_back.dart';
import 'package:car_wash_app/widgets/info_header_container.dart';
import 'package:car_wash_app/widgets/keys.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:image/image.dart' as imagePack;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/header_services.dart';
import 'carousel_cars_widget.dart';
import 'fields_invoice.dart';
import 'fields_menu_invoice.dart';

class FormInvoice extends StatefulWidget {
  final Invoice editInvoice;

  FormInvoice(this.editInvoice);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FormInvoice();
  }
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

  ///global variables
  //Esta variable _scaffoldKey se usa para poder abrir el drawer desde un boton diferente al que se coloca por defecto en el AppBar
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  GlobalKey btnAddImage = GlobalKey();
  List<String> imageList = [];
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

  final _textPlaca = TextEditingController();
  final _textClient = TextEditingController();
  final _textEmail = TextEditingController();
  final _textPhoneNumber = TextEditingController();
  String _selectOperator = "";
  String _selectCoordinator = "";
  List<User> _listOperators = <User>[];
  List<User> _listCoordinators = <User>[];
  List<Product> _listProduct = <Product>[];
  List<AdditionalProduct> _listAdditionalProducts = <AdditionalProduct>[];
  bool _validatePlaca = false;
  Customer _customer;
  DocumentReference _vehicleReference;
  int _listOperatorsCount = 0;
  int _listCoordinatorsCount = 0;

  @override
  void initState() {
    super.initState();
    _enableForm = false;
    _clientFocusNode = FocusNode();
    _listOperatorsCount = 0;
    _listCoordinatorsCount = 0;
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
      textInfo: _editForm ? 'Nueva Factura' : 'Factura Nro ${widget.editInvoice.consecutive}',
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
                sendEmail: _sendEmail,
                finalEditPlaca: _onFinalEditPlaca,
                enableForm: _enableForm,
                focusClient: _clientFocusNode,
                autofocusPlaca: widget.editInvoice == null ? true : false,
                editForm: _editForm,
              ),
              SizedBox(height: 9),
              FieldsMenusInvoice(
                listCountOperators: _listOperatorsCount,
                listCountCoordinators: _listCoordinatorsCount,
                setOperator: _setOperator,
                setCoordinator: _setCoordinator,
                cbSetOperatorsList: _setUsersOperatorsList,
                cbSetCoordinatorsList: _setUsersCoordinatorsList,
                selectedOperator: _selectOperator,
                selectedCoordinator: _selectCoordinator,
                locationReference: _locationReference,
                enableForm: _enableForm,
                editForm: _editForm,
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
                visible: _editForm,
                child: _saveInvoiceButton(),
              ),
              Visibility(
                visible: !_editForm,
                child: _rePrintInvoice(),
              ),
              SizedBox(height: 9),
            ],
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
            onPressed: _enableForm ? _menuSourceAddImage : null,
          ),
        ),
      );

  Widget _showDraw() {
    return Container(
      height: 80,
      child: Align(
        alignment: Alignment.center,
        child: RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
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
          onPressed: _editForm
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DrawPage(
                        changeValueApproveData: _callBackApproveDataprocessing,
                        callBackChargeImageFirm: _callBackChargeFirm,
                        approveDataProcessing: _approveDataProcessing,
                      ),
                    ),
                  );
                }
              : null,
        ),
      ),
    );
  }

  Widget _saveInvoiceButton() {
    return Container(
      height: 100,
      child: Align(
        alignment: Alignment.center,
        child: RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
          color: Color(0xFF59B258),
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
          onPressed: _enableForm ?? true ? _saveInvoice : null,
        ),
      ),
    );
  }

  Widget _rePrintInvoice() {
    return Container(
      height: 80,
      child: Align(
        alignment: Alignment.center,
        child: RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
          color: Color(0xFF59B258),
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
          onPressed: () {},
        ),
      ),
    );
  }

  ///Functions

  ///Image Functions
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

  ///Functions Select Menu
  void _setOperator(String selectOperator) {
    _selectOperator = selectOperator;
  }

  void _setCoordinator(String selectCoordinator) {
    _selectCoordinator = selectCoordinator;
  }

  void _setUsersOperatorsList(List<User> operatorsList) {
    _listOperators = operatorsList;
    _listOperatorsCount = _listOperators.length;
  }

  void _setUsersCoordinatorsList(List<User> coordinatorsList) {
    _listCoordinators = coordinatorsList;
    _listCoordinatorsCount = _listCoordinators.length;
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
      _validatePlaca = false;
      _enableForm = true;

      //Get vehicle if exist
      _blocVehicle
          .getVehicleReferenceByPlaca(_placa)
          .then((DocumentReference vehicleRef) {
        _vehicleReference = vehicleRef;

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
              }
            });
          });
        } else {
          setState(() {
            _cleanTextFields();
          });
        }
      });
    }
  }

  void _cleanTextFields() {
    _textClient.text = '';
    _textEmail.text = '';
    _textPhoneNumber.text = '';
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

  ///Functions Save Invoice
  void _saveInvoice() async {
    //Open message Saving
    MessagesUtils.showAlertWithLoading(context: context, title: 'Guardando')
        .show();

    try {
      DocumentReference _vehicleTypeRef;
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
        _operatorReference = await _userBloc
            .getUserReferenceById(_listOperators.firstWhere((User user) {
          return user.name == _selectOperator;
        }).uid);
      }

      //Get Coordinator reference
      if (_selectCoordinator.isNotEmpty) {
        _coordinatorReference = await _userBloc
            .getUserReferenceById(_listCoordinators.firstWhere((User user) {
          return user.name == _selectCoordinator;
        }).uid);
      }

      //Get Vehicle reference, save if not exist
      if (_vehicleReference == null) {
        Vehicle updateVehicle = Vehicle(
          brand: '',
          model: '',
          placa: _textPlaca.text.trim(),
          color: '',
          vehicleType: _vehicleTypeRef,
          creationDate: Timestamp.now(),
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
        );
        _customerReference = await _customerBloc.updateCustomer(customerUpdate);
      }

      //Get products and values
      _listProduct.forEach((product) {
        if (product.isSelected) {
          _total = _total + product.price;
          _iva = _iva + product.iva;
        }
      });
      _listAdditionalProducts.forEach((addProduct) {
        _total = _total + double.parse(addProduct.productValue ?? '0');
        _iva = _iva + addProduct.productIva;
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
        consecutive: _consecutive,
        customer: _customerReference,
        vehicle: _vehicleReference,
        placa: _textPlaca.text.trim(),
        uidVehicleType: vehicleTypeSelected.uid,
        location: _locationReference,
        locationName: _locationName,
        totalPrice: _total,
        subtotal: _subTotal,
        iva: _iva,
        userOwner: _userRef,
        userOperator: _operatorReference,
        userOperatorName: _selectOperator,
        userCoordinator: _coordinatorReference,
        userCoordinatorName: _selectCoordinator,
        creationDate: Timestamp.now(),
        invoiceImages: imageList,
        imageFirm: _imageFirmInMemory,
        approveDataProcessing: _approveDataProcessing,
      );
      DocumentReference invoiceReference =
          await _blocInvoice.saveInvoice(invoice);
      String invoiceId = invoiceReference.documentID;

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

    } on PlatformException catch (e) {
      print('$e');
      MessagesUtils.showAlert(
          context: context, title: 'Error al guardar la factura');
    } catch (error) {
      print('$error');
      MessagesUtils.showAlert(
          context: context, title: 'Error al guardar la factura');
    }
  }

  ///Set Fields Invoice to Edit
  void _editInvoice(Invoice invoiceToEdit) async {
    _textPlaca.text = invoiceToEdit.placa;
    _selectOperator = invoiceToEdit.userOperatorName;
    _selectCoordinator = invoiceToEdit.userCoordinatorName;
    Customer editCustomer = await _customerBloc
        .getCustomerByIdCustomer(invoiceToEdit.customer.documentID);
    _textClient.text = editCustomer.name;
    _textEmail.text = editCustomer.email;
    _textPhoneNumber.text = editCustomer.phoneNumber;
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
        productEditList.add(prodSelected);
      } else {
        AdditionalProduct addProd = AdditionalProduct(
          prodSelected.productName,
          prodSelected.price.toString(),
          prodSelected.iva,
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
}
