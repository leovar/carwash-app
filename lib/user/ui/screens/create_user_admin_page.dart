import 'dart:io';

import 'package:car_wash_app/invoice/ui/widgets/text_field_input.dart';
import 'package:car_wash_app/location/bloc/bloc_location.dart';
import 'package:car_wash_app/location/model/location.dart';
import 'package:car_wash_app/location/ui/screens/locations_select_list_page.dart';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/user.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:generic_bloc_provider/generic_bloc_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class CreateUserAdminPage extends StatefulWidget {
  final User currentUser;

  CreateUserAdminPage({Key key, this.currentUser});

  @override
  State<StatefulWidget> createState() => _CreateUserAdminPage();
}

class _CreateUserAdminPage extends State<CreateUserAdminPage> {
  UserBloc _userBloc;
  BlocLocation _blocLocation = BlocLocation();

  GlobalKey btnChangeImageProfile = GlobalKey();
  bool _validateName = false;
  bool _validateEmail = false;
  bool _validatePassword = false;
  final _textUserName = TextEditingController();
  final _textEmail = TextEditingController();
  final _textPassword = TextEditingController();
  final double _heightTextField = 60;
  String _imageUrl = '';
  bool _userActive = true;
  bool _userAdministrator = false;
  bool _userCoordinator = false;
  bool _userOperator = false;
  User _userSelected;
  final String _cameraTag = "Camera";
  final String _galleryTag = "Gallery";
  String _selectSourceImagePicker = "Camara";

  List<Location> _listLocation = <Location>[];

  @override
  void initState() {
    super.initState();
    if (widget.currentUser != null) {
      _userSelected = widget.currentUser;
      _imageUrl = _userSelected.photoUrl;
      _selectUserList();
    }
  }

  @override
  Widget build(BuildContext context) {
    _userBloc = BlocProvider.of(context);
    PopupMenu.context = context;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Usuario",
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
      body: SafeArea(
        child: Container(
          color: Colors.white,
          height: MediaQuery.of(context).size.height,
          child: _containerBody(),
        ),
      ),
    );
  }

  Widget _containerBody() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 17, horizontal: 16),
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: 9),
            _imageProfile(),
            SizedBox(height: 9),
            _buttonChangeImage(),
            SizedBox(height: 12),
            Flexible(
              child: Container(
                child: TextFieldInput(
                  labelText: 'Nombre del Usuario',
                  textController: _textUserName,
                  validate: _validateName,
                  textValidate: 'Escriba el nombre del usuario',
                ),
              ),
            ),
            SizedBox(height: 9),
            Container(
              height: _heightTextField,
              child: TextFieldInput(
                labelText: 'Correo',
                textController: _textEmail,
                validate: _validateEmail,
                textValidate: 'Escriba un correo valido',
                inputType: TextInputType.emailAddress,
              ),
            ),
            SizedBox(height: 9),
            Container(
              height: _heightTextField,
              child: TextFieldInput(
                labelText: 'Contraseña',
                textController: _textPassword,
                validate: _validatePassword,
                textValidate: 'Escriba una contraseña',
                isPassword: true,
              ),
            ),
            SizedBox(height: 9),
            _locationsToSelect(),
            SizedBox(height: 9),
            Flexible(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _userAdministrator,
                    onChanged: (bool value) {
                      _onChangeRol(1, value);
                    },
                    checkColor: Colors.white,
                    activeColor: Color(0xFF59B258),
                  ),
                  Text(
                    "Usuario Administrador",
                    style: TextStyle(
                      fontFamily: "Lato",
                      decoration: TextDecoration.none,
                      color: Color(0xFFAEAEAE),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 9),
            Flexible(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _userCoordinator,
                    onChanged: (bool value) {
                      _onChangeRol(2, value);
                    },
                    checkColor: Colors.white,
                    activeColor: Color(0xFF59B258),
                  ),
                  Text(
                    "Usuario Coordinador",
                    style: TextStyle(
                      fontFamily: "Lato",
                      decoration: TextDecoration.none,
                      color: Color(0xFFAEAEAE),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 9),
            Flexible(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _userOperator,
                    onChanged: (bool value) {
                      _onChangeRol(3, value);
                    },
                    checkColor: Colors.white,
                    activeColor: Color(0xFF59B258),
                  ),
                  Text(
                    "Usuario Operador",
                    style: TextStyle(
                      fontFamily: "Lato",
                      decoration: TextDecoration.none,
                      color: Color(0xFFAEAEAE),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 9),
            Flexible(
              child: Row(
                children: <Widget>[
                  Checkbox(
                    value: _userActive,
                    onChanged: (bool value) {
                      setState(() {
                        _userActive = value;
                      });
                    },
                    checkColor: Colors.white,
                    activeColor: Color(0xFF59B258),
                  ),
                  Text(
                    "Usuario Activo",
                    style: TextStyle(
                      fontFamily: "Lato",
                      decoration: TextDecoration.none,
                      color: Color(0xFFAEAEAE),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 9),
            Flexible(
              child: _buttonSave(),
            ),
            SizedBox(height: 9),
          ],
        ),
      ),
    );
  }

  Widget _locationsToSelect() {
    return StreamBuilder(
      stream: _blocLocation.locationsListStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return CircularProgressIndicator();
          default:
            return _getLocationsToSelectWidget(snapshot);
        }
      },
    );
  }

  Widget _getLocationsToSelectWidget(AsyncSnapshot snapshot) {
    if (_blocLocation.buildLocations(snapshot.data.documents).length >
        _listLocation.length) {
      _listLocation = _blocLocation.buildLocations(snapshot.data.documents);
      if (widget.currentUser != null) {
        _selectUserList();
      }
    }
    return InkWell(
      child: Container(
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 10),
              child: Text(
                '${_listLocation.where((f) => f.isSelected).toList().length} sedes agregadas',
                style: TextStyle(
                  fontFamily: "Lato",
                  decoration: TextDecoration.none,
                  color: Color(0xFF59B258),
                  fontSize: 17,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          color: Color(0xFFF1F1F1),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LocationsSelectListPage(
              callbackSetLocationsList: _setLocationsDb,
              locationsList: _listLocation,
            ),
          ),
        );
      },
    );
  }

  Widget _imageProfile() {
    return Container(
      margin: EdgeInsets.only(left: 8, right: 18),
      alignment: Alignment.centerLeft,
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: Colors.grey,
        ),
        shape: BoxShape.circle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: _getProfileImageProvider(),
        ),
      ),
    );
  }

  Widget _buttonChangeImage() {
    return Center(
      child: Container(
        height: 55,
        child: Align(
          alignment: Alignment.center,
          child: RaisedButton(
            key: btnChangeImageProfile,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 17),
            color: Color(0xFF59B258),
            child: Text(
              "Cambiar Imagen",
              style: TextStyle(
                fontFamily: "Lato",
                decoration: TextDecoration.none,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            onPressed: () {
              _changeProfileImage();
            },
          ),
        ),
      ),
    );
  }

  Widget _buttonSave() {
    return Container(
      height: 100,
      child: Align(
        alignment: Alignment.center,
        child: RaisedButton(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
          color: Color(0xFF59B258),
          child: Text(
            "Guardar",
            style: TextStyle(
              fontFamily: "Lato",
              decoration: TextDecoration.none,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 19,
            ),
          ),
          onPressed: () {
            _saveUser();
          },
        ),
      ),
    );
  }

  /// Functions
  void _setLocationsDb(List<Location> locationsListSelected) {
    setState(() {
      _listLocation = locationsListSelected;
    });
  }

  ///Function Images
  ImageProvider _getProfileImageProvider() {
    if (_imageUrl.isNotEmpty && _imageUrl.contains('https://')) {
      return NetworkImage(_imageUrl);
    } else if (_imageUrl.isNotEmpty) {
      return FileImage(File(_imageUrl));
    } else {
      return AssetImage('assets/images/profile_placeholder.png');
    }
  }

  void _changeProfileImage() {
    PopupMenu menu = PopupMenu(
        backgroundColor: Color(0xFF59B258),
        lineColor: Color(0xFF59B258),
        maxColumn: 1,
        items: [
          MenuItem(
              title: _cameraTag,
              textStyle: TextStyle(color: Colors.white),
              image: Icon(
                Icons.camera_alt,
                color: Colors.white,
              )),
          MenuItem(
              title: _galleryTag,
              textStyle: TextStyle(color: Colors.white),
              image: Icon(
                Icons.image,
                color: Colors.white,
              )),
        ],
        onClickMenu: _onClickMenuImageSelected);
    menu.show(widgetKey: btnChangeImageProfile);
  }

  void _onClickMenuImageSelected(MenuItemProvider item) {
    _selectSourceImagePicker = item.menuTitle;
    _addImageTour();
    print('Click menu -> ${item.menuTitle}');
  }

  Future _addImageTour() async {
    var imageCapture = await ImagePicker.pickImage(
            source: _selectSourceImagePicker == _cameraTag
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
      final dir = await path_provider.getTemporaryDirectory();
      final targetPath = dir.absolute.path +
          "/${imageCapture.path.substring(imageCapture.path.length - 10, imageCapture.path.length)}"; //dir.absolute.path + "/temp${imageList.length}.jpg";
      File fileCompress = await FlutterImageCompress.compressAndGetFile(
        croppedFile.absolute.path,
        targetPath,
        quality: 40,
      );

      setState(() {
        _imageUrl = fileCompress.path;
      });
    }
  }

  //1. administrator, 2. coordinator, 3. Operator
  void _onChangeRol(int rol, bool value) {
    setState(() {
      switch (rol) {
        case 1:
          _userAdministrator = value;
          _userOperator = false;
          _userCoordinator = false;
          break;
        case 2:
          _userAdministrator = false;
          //_userOperator = false; // Se comenta por que un uusario coordinador también puede ser operador
          _userCoordinator = value;
          break;
        case 3:
          _userAdministrator = false;
          _userOperator = value;
          //_userCoordinator = false;
          break;
      }
    });
  }

  ///Function user selected
  void _selectUserList() {
    _validateName = false;
    _validateEmail = false;
    _validatePassword = false;
    _textUserName.text = _userSelected.name;
    _textEmail.text = _userSelected.email;
    _textPassword.text = '';
    _userActive = _userSelected.active;
    _userAdministrator = _userSelected.isAdministrator;
    _userCoordinator = _userSelected.isCoordinator;
    _userOperator = _userSelected.isOperator;
    _listLocation.forEach((Location loc) {
      List<DocumentReference> dr =
          _userSelected.locations.where((e) => e.documentID == loc.id).toList();
      if (dr.length > 0) {
        _listLocation[_listLocation.indexOf(loc)].isSelected = true;
      } else {
        _listLocation[_listLocation.indexOf(loc)].isSelected = false;
      }
    });
  }

  bool _validateInputs() {
    bool canSave = true;
    if (_textUserName.text.isEmpty) {
      _validateName = true;
      canSave = false;
    } else
      _validateName = false;

    if (_textEmail.text.isEmpty) {
      _validateEmail = true;
      canSave = false;
    } else
      _validateEmail = false;

    if (widget.currentUser == null) {
      if (_textPassword.text.isEmpty) {
        _validatePassword = true;
        canSave = false;
      } else
        _validatePassword = false;
    }

    if (canSave == false) {
      setState(() {
        MessagesUtils.showAlert(
                context: context, title: 'Faltan campos por llenar')
            .show();
      });
    }

    return canSave;
  }

  void _clearData() {
    _textUserName.text = '';
    _textEmail.text = '';
    _textPassword.text = '';
    _userAdministrator = false;
    _userCoordinator = false;
    _userOperator = false;
    _userActive = true;
    setState(() {
      _listLocation.forEach((f) {
        _listLocation[_listLocation.indexOf(f)].isSelected = false;
      });
    });
  }

  Future<void> _saveUser() async {
    if (_validateInputs()) {
      try {
        MessagesUtils.showAlertWithLoading(context: context, title: 'Guardando')
            .show();

        //Add new locations at user exist
        if (_userSelected != null) {
          _listLocation.where((l) => l.isSelected).toList().forEach((f) {
            List<DocumentReference> listFind = _userSelected.locations
                .where((e) => e.documentID == f.id)
                .toList();
            if (listFind.length <= 0) {
              _userSelected.locations
                  .add(_blocLocation.getDocumentReferenceLocationById(f.id));
            }
          });
        }

        //Delete locations at user exist
        if (_userSelected != null) {
          List<DocumentReference> locListDeleted = <DocumentReference>[];
          _userSelected.locations.forEach((item) {
            locListDeleted.add(item);
          });
          _userSelected.locations.forEach((DocumentReference locRefDelete) {
            List<Location> lotionsFind = _listLocation
                .where((f) => f.id == locRefDelete.documentID && f.isSelected)
                .toList();
            if (lotionsFind.length == 0) {
              locListDeleted
                  .removeAt(_userSelected.locations.indexOf(locRefDelete));
            }
          });
          _userSelected.locations.clear();
          locListDeleted.forEach((d) {
            _userSelected.locations.add(d);
          });
        }

        List<DocumentReference> _newListLocationsReferences =
            <DocumentReference>[];
        _listLocation.where((d) => d.isSelected).toList().forEach((f) {
          _newListLocationsReferences
              .add(_blocLocation.getDocumentReferenceLocationById(f.id));
        });

        //New User save in firestore
        String userNewRegister;
        if (_userSelected == null) {
          userNewRegister = await _userBloc.registerEmailUser(
              _textEmail.text.trim(), _textPassword.text.trim());
        }

        final user = User(
          id: _userSelected != null ? _userSelected.id : null,
          uid: _userSelected != null ? _userSelected.uid : userNewRegister,
          name: _textUserName.text.trim(),
          email: _textEmail.text.toLowerCase().trim(),
          photoUrl: _imageUrl,
          lastSignIn: Timestamp.now(),
          active: _userActive,
          locations: _userSelected != null
              ? _userSelected.locations
              : _newListLocationsReferences,
          isAdministrator: _userAdministrator,
          isCoordinator: _userCoordinator,
          isOperator: _userOperator,
        );

        await _userBloc.updateUserData(user);

        Navigator.pop(context);
        Navigator.pop(context);
        /*
        MessagesUtils.showAlert(
          context: context,
          title: 'Usuario guardado',
          alertType: AlertType.success,
        ).show();
        */
      } on PlatformException catch (_) {
        Navigator.pop(context);
        print(_);
        if (_.message ==
            'The email address is already in use by another account.') {
          MessagesUtils.showAlert(
            context: context,
            title: 'El usuario ya se encuentra registrado',
            alertType: AlertType.info,
          ).show();
        }
      }
      _clearData();
    }
  }
}
