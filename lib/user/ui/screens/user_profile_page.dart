import 'dart:io';

import 'package:car_wash_app/customer/bloc/bloc_customer.dart';
import 'package:car_wash_app/customer/model/customer.dart';
import 'package:car_wash_app/invoice/ui/widgets/text_field_input.dart';
import 'package:car_wash_app/user/bloc/bloc_user.dart';
import 'package:car_wash_app/user/model/sysUser.dart';
import 'package:car_wash_app/widgets/keys.dart';
import 'package:car_wash_app/widgets/messages_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:popup_menu/popup_menu.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserProfilePage();
}

class _UserProfilePage extends State<UserProfilePage> {
  UserBloc _userBloc = UserBloc();
  BlocCustomer _customerBloc = BlocCustomer();

  GlobalKey btnChangeImageProfile = GlobalKey();
  bool _validateName = false;
  final _textUserName = TextEditingController();
  final _textEmail = TextEditingController();
  final _textPassword = TextEditingController();
  final _textPhone = TextEditingController();
  final _textNeighborhood = TextEditingController();
  final _textBirthDate = TextEditingController();
  final double _heightTextField = 60;
  String _imageUrl = '';
  late SysUser _currentUser;
  Customer _currentCustomer = Customer();
  bool _obscureText = true;
  DateTime _date = new DateTime.now();
  String _oldTextBirthDay = '';
  final String _cameraTag = "Camera";
  final String _galleryTag = "Gallery";
  String _selectSourceImagePicker = "Camara";

  @override
  void initState() {
    super.initState();
    this._getUser();
  }

  @override
  Widget build(BuildContext context) {
    //_userBloc = BlocProvider.of(context);
    //PopupMenu.context = context;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 30,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Perfil",
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
                inputType: TextInputType.emailAddress,
                enable: false,
              ),
            ),
            SizedBox(height: 9),
            /* no se implementa el update pasword para esta versión por que no funciona correctamente
            Container(
              height: _heightTextField,
              child: this._inputTextPassword(),
            ),
            SizedBox(height: 9),*/
            TextFieldInput(
              labelText: "Telefono",
              textController: _textPhone,
              inputType: TextInputType.number,
              autofocus: false,
              maxLength: 10,
            ),
            SizedBox(height: 9),
            TextFieldInput(
              labelText: "Barrio",
              textController: _textNeighborhood,
              maxLines: 1,
            ),
            SizedBox(height: 9),
            TextFieldInput(
              labelText: "Fecha de Nacimiento (dd/mm/aaaa)",
              textController: _textBirthDate,
              hintText: 'dd/mm/aaaa',
              inputType: TextInputType.datetime,
              textInputFormatter: [
                FilteringTextInputFormatter.allow(
                  RegExp('^[0-9]*\/*[0-9]*\/*[0-9]*'),
                ),
              ],
              onFinalEditText: _onChangeTextBirthDate,
            ),
            SizedBox(height: 9),
            Flexible(child: _buttonSave()),
            SizedBox(height: 9),
          ],
        ),
      ),
    );
  }

  Widget _imageProfile() {
    return Container(
      margin: EdgeInsets.only(left: 8, right: 18),
      alignment: Alignment.centerLeft,
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Colors.grey),
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
          child: ElevatedButton(
            key: btnChangeImageProfile,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 17),
              backgroundColor: Color(0xFF59B258),
            ),
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

  Widget _inputTextPassword() {
    return TextFormField(
      controller: _textPassword,
      maxLines: 1,
      obscureText: _obscureText,
      cursorColor: Color(0xFFAEAEAE),
      style: TextStyle(
        fontFamily: "Lato",
        decoration: TextDecoration.none,
        color: Color(0xFFAEAEAE),
        fontSize: 18,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 17, horizontal: 15),
        labelText: 'Nueva contraseña',
        labelStyle: TextStyle(
          decoration: TextDecoration.none,
          fontFamily: "Lato",
          color: Color(0xFFAEAEAE),
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFAEAEAE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 2, color: Color(0xFFAEAEAE)),
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: Color(0xFFAEAEAE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(width: 1, color: Color(0xFFAEAEAE)),
        ),
        suffixIcon: InkWell(
          onTap: () => this._togglePassword(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: _obscureText
                ? Icon(Icons.visibility, color: Color(0xFFAEAEAE))
                : Icon(Icons.visibility_off, color: Color(0xFFAEAEAE)),
          ),
        ),
      ),
      validator: (args) {
        if (args!.isEmpty)
          return 'El campo no puede estar vacio';
        else
          return null;
      },
    );
  }

  Widget _buttonSave() {
    return Container(
      height: 100,
      child: Align(
        alignment: Alignment.center,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 60),
            backgroundColor: Color(0xFF59B258),
          ),
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
      context: context,
      config: MenuConfig(
        backgroundColor: Color(0xFF59B258),
        lineColor: Color(0xFF59B258),
        maxColumn: 1,
      ),
      items: [
        MenuItem(
          title: _cameraTag,
          textStyle: TextStyle(color: Colors.white),
          image: Icon(Icons.camera_alt, color: Colors.white),
        ),
        MenuItem(
          title: _galleryTag,
          textStyle: TextStyle(color: Colors.white),
          image: Icon(Icons.image, color: Colors.white),
        ),
      ],
      onClickMenu: _onClickMenuImageSelected,
    );
    menu.show(widgetKey: btnChangeImageProfile);
  }

  void _onClickMenuImageSelected(MenuItemProvider item) {
    _selectSourceImagePicker = item.menuTitle;
    _addImageTour();
    print('Click menu -> ${item.menuTitle}');
  }

  Future _addImageTour() async {
    final XFile? imageCapture = await ImagePicker()
        .pickImage(
            source: _selectSourceImagePicker == _cameraTag
                ? ImageSource.camera
                : ImageSource.gallery,
            preferredCameraDevice: CameraDevice.front)
        .catchError((onError) => print(onError));

    if (imageCapture != null) {
      setState(() {
        _cropImage(imageCapture);
      });
    }
  }

  Future<Null> _cropImage(imageCapture) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageCapture.path,
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
      ],
    );
    final dir = await path_provider.getTemporaryDirectory();
    final targetPath = dir.absolute.path +
        "/${imageCapture.path.substring(imageCapture.path.length - 10, imageCapture.path.length)}"; //dir.absolute.path + "/temp${imageList.length}.jpg";
    final XFile? fileCompress = await FlutterImageCompress.compressAndGetFile(
      croppedFile!.path,
      targetPath,
      quality: 30,
    );

    setState(() {
      _imageUrl = fileCompress!.path;
    });
  }

  // Toggles the password show status
  void _togglePassword() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  //Change Text Birth Date
  void _onChangeTextBirthDate() {
    var text = _textBirthDate.text;
    List<String> val = _textBirthDate.text.split('/');
    var val1 = int.tryParse(val[0].isNotEmpty ? val[0] : '0');
    var val2 = int.tryParse(val.length > 1 ? val[1] : '0');
    var val3 = int.tryParse(val.length > 2 ? val[2] : '0');

    if (text.length > 10) {
      _textBirthDate.text = _oldTextBirthDay;
      _textBirthDate.selection = TextSelection.fromPosition(
        TextPosition(offset: _textBirthDate.text.length),
      );
      return;
    }

    if (text.length > _oldTextBirthDay.length) {
      if (text.length > 2 && text.length < 4) {
        _textBirthDate.text =
            text.substring(0, 2) + '/' + text.substring(2, text.length);
        _textBirthDate.selection = TextSelection.fromPosition(
          TextPosition(offset: _textBirthDate.text.length),
        );
      } else if (text.length > 5 && text.length < 7) {
        _textBirthDate.text =
            text.substring(0, 5) + '/' + text.substring(5, text.length);
        _textBirthDate.selection = TextSelection.fromPosition(
          TextPosition(offset: _textBirthDate.text.length),
        );
      }

      if (val1! > 31 && val1.toString().length == 2) {
        MessagesUtils.showAlert(
          context: context,
          title: 'El dia no puede ser superior a 31',
          alertType: AlertType.warning,
        ).show();
      }

      if (val2! > 12 && val2.toString().length == 2) {
        MessagesUtils.showAlert(
          context: context,
          title: 'El mes no puede ser superior a 12',
          alertType: AlertType.warning,
        ).show();
      }

      if (val3! > 0 &&
          val3.toString().length == 4 &&
          (val3 < 1900 || val3 >= DateTime.now().year)) {
        MessagesUtils.showAlert(
          context: context,
          title: 'Ingrese un año válido',
          alertType: AlertType.warning,
        ).show();
      }
    }
    _oldTextBirthDay = text;
  }

  ///Function user selected
  void _selectUserList() {
    _validateName = false;
    _textUserName.text = _currentUser.name ?? '';
    _textEmail.text = _currentUser.email;
    _textPassword.text = '';
    _textPhone.text = _currentCustomer.phoneNumber ?? '';
    _textNeighborhood.text = _currentCustomer.neighborhood ?? '';
    _textBirthDate.text = _currentCustomer.birthDate ?? '';
    setState(() {
      _imageUrl = _currentUser.photoUrl ?? '';
    });
  }

  void _getUser() {
    _userBloc.getCurrentUser().then((user) {
      _currentUser = user?? new SysUser(uid: '', name: '', email: '');
      _updatePreference();
      this._selectUserList();
      _customerBloc.getCustomerFilter('', user?.email ?? '').then((customer) {
        if (customer.length > 0) {
          _currentCustomer = customer[0];
          this._selectUserList();
        }
      });
    });
  }

  bool _validateInputs() {
    bool canSave = true;
    if (_textUserName.text.isEmpty) {
      _validateName = true;
      canSave = false;
    } else
      _validateName = false;

    /*
    if (_textEmail.text.isEmpty) {
      _validateEmail = true;
      canSave = false;
    } else
      _validateEmail = false;
     */

    if (canSave == false) {
      setState(() {
        MessagesUtils.showAlert(
          context: context,
          title: 'Faltan campos por llenar',
        ).show();
      });
    }

    return canSave;
  }

  void _updatePreference() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(Keys.photoUserUrl, _currentUser.photoUrl ?? '');
    pref.setString(Keys.userName, _currentUser.name);
    pref.setString(Keys.userEmail, _currentUser.email);
  }

  Future<void> _saveUser() async {
    if (_validateInputs()) {
      try {
        MessagesUtils.showAlertWithLoading(
          context: context,
          title: 'Guardando',
        ).show();

        //Update email if is required
        if (_currentUser.email != _textEmail.text.trim()) {
          await _userBloc.updateEmailUser(_textEmail.text.trim().toLowerCase());
        }

        //Update password if is required, 'el update password no funciona correctamente en flutter'
        if (_textPassword.text.trim().isNotEmpty) {
          await _userBloc.updatePasswordUser(_textEmail.text.trim());
        }

        // Update user db Info
        final user = SysUser.copyWith(
          origin: _currentUser,
          name: _textUserName.text.trim(),
          email: _textEmail.text.trim(),
          photoUrl: _imageUrl,
        );
        await _userBloc.updateUserData(user);

        // Update Customer
        final customerCopy = Customer.copyWith(
          origin: _currentCustomer,
          phoneNumber: _textPhone.text.trim(),
          neighborhood: _textNeighborhood.text.trim(),
          birthDate: _textBirthDate.text.trim(),
        );
        await _customerBloc.updateCustomer(customerCopy);
        _getUser();

        Navigator.pop(context);
        //Navigator.of(context, rootNavigator: true)..pop()..pop();
        MessagesUtils.showAlert(
          context: context,
          title: 'Perfil guardado',
          alertType: AlertType.success,
        ).show();
      } catch (error) {
        Navigator.pop(context);
        MessagesUtils.showAlert(
          context: context,
          title: 'Error actualizando el perfil',
          alertType: AlertType.info,
        ).show();
      }
      //_clearData();
    }
  }
}
