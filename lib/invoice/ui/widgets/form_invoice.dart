import 'dart:io';

import 'package:car_wash_app/customer/bloc/bloc_customer.dart';
import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/invoice/bloc/bloc_invoice.dart';
import 'package:car_wash_app/invoice/model/additional_product.dart';
import 'package:car_wash_app/invoice/model/invoice.dart';
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
import 'package:car_wash_app/widgets/keys.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'carousel_cars_widget.dart';
import 'fields_invoice.dart';
import '../../model/header_services.dart';
import 'fields_menu_invoice.dart';

class FormInvoice extends StatefulWidget {
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

  ///global variables
  //Esta variable _scaffoldKey se usa para poder abrir el drawer desde un boton diferente al que se coloca por defecto en el AppBar
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  GlobalKey btnAddImage = GlobalKey();
  List<String> imageList = [];
  bool _sendEmail = false;
  List<HeaderServices> vehicleTypeList = new List<HeaderServices>();
  HeaderServices vehicleTypeSelected;
  final String cameraTag = "Camara";
  final String galleryTag = "Galeria";
  String _selectSourceImagePicker = "Camara";
  File _imageSelect;
  FocusNode _clientFocusNode;

  final _textPlaca = TextEditingController();
  final _textClient = TextEditingController();
  final _textEmail = TextEditingController();
  String _selectOperator = "";
  String _selectCoordinator = "";
  List<User> _listOperators = <User>[];
  List<User> _listCoordinators = <User>[];
  List<Product> _listProduct = <Product>[];
  List<AdditionalProduct> _listAdditionalProducts = <AdditionalProduct>[];
  bool _validatePlaca = false;
  Customer _customer;
  DocumentReference _vehicleReference;

  @override
  void initState() {
    super.initState();
    _enableForm = false;
    _clientFocusNode = FocusNode();
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
    vehicleTypeSelected = vehicleTypeList[0];
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
    //FocusScope.of(context).requestFocus(_placaFocusNode);

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
                vehicleTypeSelected = vehicleTypeList[index];
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
          child: Column(
            children: <Widget>[
              FieldsInvoice(
                textPlaca: _textPlaca,
                validatePlaca: _validatePlaca,
                textClient: _textClient,
                textEmail: _textEmail,
                sendEmail: _sendEmail,
                finalEditPlaca: _onFinalEditPlaca,
                enableForm: _enableForm,
                focusClient: _clientFocusNode,
                autofocusPlaca: true,
              ),
              SizedBox(
                height: 9,
              ),
              FieldsMenusInvoice(
                setOperator: _setOperator,
                setCoordinator: _setCoordinator,
                cbSetOperatorsList: _setUsersOperatorsList,
                cbSetCoordinatorsList: _setUsersCoordinatorsList,
                selectedOperator: _selectOperator,
                selectedCoordinator: _selectCoordinator,
                enableForm: _enableForm,
              ),
              SizedBox(
                height: 9,
              ),
              FieldsProducts(
                callbackProductsList: _setProductsDb,
                productListCallback: _listProduct,
                callbackAdditionalProdList: _setAdditionalProducts,
                additionalProductListCb: _listAdditionalProducts,
                vehicleTypeSelect: vehicleTypeSelected,
                enableForm: _enableForm,
              ),
              SizedBox(
                height: 9,
              ),
              saveInvoice(),
              SizedBox(
                height: 9,
              ),
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
            onPressed: _enableForm? _menuSourceAddImage: null,
          ),
        ),
      );

  Widget saveInvoice() {
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
          onPressed: _enableForm??true ?  _saveInvoice : null,
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

  void _setUsersOperatorsList(List<User> operatorsList){
    _listOperators = operatorsList;
  }

  void _setUsersCoordinatorsList(List<User> coordinatorsList){
    _listCoordinators = coordinatorsList;
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
    String placa = _textPlaca.text??'';

    if (placa.isEmpty) {
      setState(() {
        _validatePlaca = true;
        _enableForm = false;
      });
    } else {

      //Get vehicle if exist
      _blocVehicle.getVehicleReferenceByPlaca(placa).then((DocumentReference vehicleRef) {
        _vehicleReference = vehicleRef;
      });

      //Get Customer if exist
      _customerBloc.getCustomerByVehicle(placa).then((Customer customer) {
        setState(() {
          if (customer == null) {
            FocusScope.of(context).requestFocus(_clientFocusNode);
            _validatePlaca = false;
            _enableForm = true;
          } else {
            _customer = customer;
            _textClient.text = customer.name;
            _textEmail.text = customer.email;
          }
        });
      });
    }
  }

  ///Functions Save Invoice
  void _saveInvoice() async {
    DocumentReference _vehicleTypeRef;
    DocumentReference _customerReference;
    DocumentReference _operatorRefererence;
    DocumentReference _coordinatorRefererence;
    DocumentReference _locationReference;

    //Get Current user reference
    DocumentReference _userRef = await _userBloc.getUserReference();

    //Get Operator reference
    _operatorRefererence = await _userBloc.getUserReferenceById(_listOperators.firstWhere((User user){
      return user.name == _selectOperator;
    }).uid);

    //Get Coordinator reference
    _coordinatorRefererence = await _userBloc.getUserReferenceById(_listCoordinators.firstWhere((User user) {
      return user.name == _selectCoordinator;
    }).uid);


    //Get VehicleType reference
    _vehicleTypeRef = await _blocInvoice.getVehicleTypeReference(vehicleTypeSelected.text);

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
      DocumentReference vehicleRef = await _blocVehicle.updateVehicle(updateVehicle);
      _vehicleReference = vehicleRef;
    }

    //Get Customer reference
    if (_customer ==  null) {
      List<DocumentReference> listVehicles = <DocumentReference>[];
      listVehicles.add(_vehicleReference);

      Customer customer = Customer(
        name: _textClient.text.trim(),
        address: '',
        phoneNumber: '',
        email: _textEmail.text.trim(),
        creationDate: Timestamp.now(),
        vehicles: listVehicles,
      );
      DocumentReference customerRef = await _customerBloc.updateCustomer(customer);
      _customerReference = customerRef;
    }

    //Get products and values
    SharedPreferences pref = await SharedPreferences.getInstance();
    String idLocation = pref.getString(Keys.locations);
    _locationReference = await _locationBloc.getLocationReference(idLocation);

    final invoice = Invoice(
      customer: _customerReference,
      vehicle: _vehicleReference,
      location: _locationReference,
      totalPrice: 25000,
      subtotal: 3500,
      iva: 2500,
      userOwner: _userRef,
      userOperator: _operatorRefererence,
      userCoordinator: _coordinatorRefererence,
      invoiceImages: imageList,
    );
    _blocInvoice.saveInvoice(invoice);
  }
}
