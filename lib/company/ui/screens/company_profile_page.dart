import 'package:car_wash_app/company/bloc/bloc_company.dart';
import 'package:car_wash_app/company/model/company.dart';
import 'package:car_wash_app/company/model/municipality.dart';
import 'package:car_wash_app/company/model/region.dart';
import 'package:car_wash_app/widgets/popup_menu_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../invoice/ui/widgets/text_field_input.dart';
import '../../../widgets/keys.dart';
import '../../../widgets/messages_utils.dart';

class CompanyProfilePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CompanyProfilePage();
}

class _CompanyProfilePage extends State<CompanyProfilePage> {
  BlocCompany _blocCompany = BlocCompany();

  final _textCompanyName = TextEditingController();
  final _textContactName = TextEditingController();
  final _textEmail = TextEditingController();
  final _textPrincipalPhone = TextEditingController();
  final _textAddress = TextEditingController();
  final _textLicenceType = TextEditingController();
  final _textCode = TextEditingController();
  final _textNextRenewal = TextEditingController();
  final _textNit = TextEditingController();
  final double _heightTextField = 60;
  bool _validateCompanyName = false;
  bool _validateContactName = false;
  bool _validateEmail = false;
  bool _validateNit = false;
  bool _validatePhone = false;
  String _companyId = '';
  late Company _companySelected;

  List<Region> _listRegionsObjects = [];
  List<String> _listTypeRegions = [];
  List<String> _listMunicipalities = [];
  String _selectNameRegion = '';
  String _selectedNameMunicipality = '';
  late Region _selectedRegionObject;

  @override
  void initState() {
    super.initState();
    _companySelected = new Company(
      active: false,
      city: '',
      companyCode: 0,
      companyName: '',
      contactName: '',
      contactUsers: [],
      country: '',
      creationDate: Timestamp.now(),
      endDate: Timestamp.now(),
      licenseMonths: 0,
      licenseType: '',
      licenseTypeCode:0,
      nit: '',
      phone: '',
      startDate: Timestamp.now(),
      region: '',
    );
    _getPreferences();
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
          "Compañia",
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
          children: [
            //SizedBox(height: 9),
            //_imageProfile(),
            SizedBox(height: 9),
            Flexible(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Información de la compañia",
                  style: TextStyle(
                    fontFamily: "Lato",
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Divider(
              height: 5,
              color: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(height: 12),
            Flexible(
              child: Container(
                child: TextFieldInput(
                  labelText: 'Nombre de la compañia',
                  textController: _textCompanyName,
                  textValidate: 'Escriba el nombre de la compañia',
                  validate: _validateCompanyName,
                ),
              ),
            ),
            SizedBox(height: 9),
            Flexible(
              child: Container(
                child: TextFieldInput(
                  labelText: 'Nit de la compañia',
                  textController: _textNit,
                  textValidate: 'Escriba el nit de la compañia',
                  validate: _validateNit,
                ),
              ),
            ),
            SizedBox(height: 9),
            Flexible(
              child: TextFieldInput(
                labelText: 'Nombre del encargado',
                textController: _textContactName,
                textValidate: 'Escriba el nombre del contacto',
                validate: _validateContactName,
              ),
            ),
            SizedBox(height: 9),
            Container(
              height: _heightTextField,
              child: TextFieldInput(
                labelText: 'Correo',
                textController: _textEmail,
                inputType: TextInputType.emailAddress,
                enable: true,
                validate: _validateEmail,
              ),
            ),
            SizedBox(height: 9),
            TextFieldInput(
              labelText: "Telefono",
              textController: _textPrincipalPhone,
              inputType: TextInputType.number,
              enable: true,
              autofocus: false,
              maxLength: 10,
              validate: _validatePhone,
              textInputFormatter: [
                FilteringTextInputFormatter.allow(RegExp("^[0-9.]*")),
              ],
            ),
            SizedBox(height: 9),
            Flexible(
              child: _regionList(),
            ),
            SizedBox(height: 9),
            Flexible(
              child: _municipalitiesList(),
            ),
            SizedBox(height: 9),
            Flexible(
              child: TextFieldInput(
                labelText: 'Dirección',
                textController: _textAddress,
                textValidate: 'Escriba el dirección de la compañia',
              ),
            ),
            SizedBox(height: 20),
            Flexible(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Información de la subscripción",
                  style: TextStyle(
                    fontFamily: "Lato",
                    decoration: TextDecoration.none,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            Divider(
              height: 5,
              color: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(height: 12),
            Flexible(
              child: TextFieldInput(
                labelText: 'Tipo de licencia',
                textController: _textLicenceType,
                enable: false,
              ),
            ),
            SizedBox(height: 9),
            Flexible(
              child: TextFieldInput(
                labelText: 'Próxima renovación',
                textController: _textNextRenewal,
                enable: false,
              ),
            ),
            SizedBox(height: 9),
            Flexible(
              child: TextFieldInput(
                labelText: 'Código de compañia',
                textController: _textCode,
                enable: false,
              ),
            ),
            SizedBox(height: 9),
            Flexible(child: _buttonSave()),
            SizedBox(height: 12),
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
        shape: BoxShape.rectangle,
        image: DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage('assets/images/profile_placeholder.png'),
        ),
      ),
    );
  }

  /// Region filter section
  Widget _regionList() {
    return StreamBuilder(
      stream: _blocCompany.regionsStream(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Center(child: CircularProgressIndicator());
          default:
            return _chargeDropRegions(snapshot);
        }
      },
    );
  }

  Widget _chargeDropRegions(AsyncSnapshot snapshot) {
    _listRegionsObjects = _blocCompany.buildRegions(snapshot.data.docs);
    if (_listTypeRegions.isEmpty) {
      getListRegions(_listRegionsObjects);
    }

    return PopUpMenuWidget(
      popUpName: 'Departamento',
      selectValue: onChangeDropRegion,
      listString: _listTypeRegions,
      valueSelect: _selectNameRegion,
      enableForm: true,
      editForm: false,
    );
  }

  Widget _municipalitiesList() {
    return PopUpMenuWidget(
      popUpName: 'Municipio',
      selectValue: onChangeDropMunicipalities,
      listString: _listMunicipalities,
      valueSelect: _selectedNameMunicipality,
      enableForm: true,
      editForm: true,
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
            _saveCompany();
          },
        ),
      ),
    );
  }

  /// Functions
  onChangeDropRegion(String selectedRegion) async {
    _selectNameRegion = selectedRegion;
    _selectedRegionObject = _listRegionsObjects.firstWhere((item) => item.name == selectedRegion);
    _listMunicipalities.replaceRange(0, _listMunicipalities.length,
        _selectedRegionObject.municipalities.map((item) => item.name).toList());
  }

  void getListRegions(List<Region> listRegions) {
    for (Region item in listRegions) {
      _listTypeRegions.add(item.name);
    }
  }

  onChangeDropMunicipalities(String selectedValue) async {
    _selectedNameMunicipality = selectedValue;
  }

  Future<void> _saveCompany() async {
    if (_validateInputs()) {
      try {
        MessagesUtils.showAlertWithLoading(
          context: context,
          title: 'Guardando',
        ).show();

        final company =  Company.copyWith(
          origin: _companySelected,
          companyName: _textCompanyName.text.trim(),
          contactName: _textContactName.text.trim(),
          nit: _textNit.text.trim(),
          email: _textEmail.text.trim(),
          phone: _textPrincipalPhone.text.trim(),
          address: _textAddress.text.trim(),
          region: _selectNameRegion,
          city: _selectedNameMunicipality,
        );

        await _blocCompany.updateCompanyInformation(company);
        Navigator.pop(context);
        Navigator.pop(context);

      } catch(_error) {
        Navigator.pop(context);
        MessagesUtils.showAlert(
          context: context,
          title: 'Error guardando: ${_error}',
          alertType: AlertType.info,
        ).show();
      }
    }
  }

  Future<void> _getPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (_companyId.isEmpty) {
      setState(() {
        _companyId = pref.getString(Keys.companyId) ?? '';
        _getCompanyInformation(_companyId);
      });
    }
  }

  void _getCompanyInformation(String companyId) async {
    _companySelected = await _blocCompany.getCompanyInformation(companyId);
    _textCompanyName.text = _companySelected.companyName;
    _textContactName.text = _companySelected.contactName;
    _textNit.text = _companySelected.nit;
    _textEmail.text = _companySelected.email??'';
    _textPrincipalPhone.text = _companySelected.phone;
    _textAddress.text = _companySelected.address??'';
    _textLicenceType.text = _companySelected.licenseType;
    _textCode.text = _companySelected.companyCode.toString();
    _textNextRenewal.text = _companySelected.endDate.toDate().toString().substring(0,10);
    if (_listRegionsObjects.isNotEmpty) {
      setState(() {
        _selectNameRegion = _companySelected.region;
        onChangeDropRegion(_selectNameRegion);
        _selectedNameMunicipality = _companySelected.city;
      });
    }
  }

  bool _validateInputs() {
    bool canSave = true;
    if (_textCompanyName.text.isEmpty) {
      _validateCompanyName = true;
      canSave = false;
    } else
      _validateCompanyName = false;

    if (_textContactName.text.isEmpty) {
      _validateContactName = true;
      canSave = false;
    } else
      _validateContactName = false;

    if (_textEmail.text.isEmpty) {
      _validateEmail = true;
      canSave = false;
    } else
      _validateEmail = false;

    if (_textNit.text.isEmpty) {
      _validateNit = true;
      canSave = false;
    } else
      _validateNit = false;

    if (_textPrincipalPhone.text.isEmpty) {
      _validatePhone = true;
      canSave = false;
    } else
      _validatePhone = false;

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
}
