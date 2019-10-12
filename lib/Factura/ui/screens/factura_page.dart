import 'package:car_wash_app/Factura/ui/widgets/carousel_test.dart' as prefix0;
import 'package:car_wash_app/User/model/user.dart';
import 'package:car_wash_app/widgets/header_menu_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:car_wash_app/widgets/drawer_page.dart';
import 'package:car_wash_app/widgets/gradient_back.dart';
import 'package:car_wash_app/Factura/ui/widgets/radio_item.dart';
import 'package:car_wash_app/Factura/ui/widgets/carousel_test.dart';
import 'package:car_wash_app/Factura/ui/widgets/campos_factura.dart';
import 'package:car_wash_app/widgets/app_bar_widget.dart';

class FacturaPage extends StatefulWidget {
  final User usuario;
  bool showDrawer = true;

  FacturaPage({Key key, @required this.usuario, this.showDrawer});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FacturaPage();
  }
}

class _FacturaPage extends State<FacturaPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  bool _sendEmail = false;
  List<RadioModel> sampleData = new List<RadioModel>();
  var _operadores = ["Juan antonio", "Ernesto", "Camilo Villa"];
  var _coordinadores = ["Antonio", "Juan esteban", "Carlos andres"];
  String _currenOperatorSelected = "Ernesto";
  String _currenCoordinadorSelected = "Juan esteban";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sampleData.add(new RadioModel(false, "Auto", 38,
        "assets/images/icon_car_admin.png", "assets/images/icon_car.png"));
    sampleData.add(new RadioModel(
        false,
        "Camioneta",
        37,
        'assets/images/icon_suv_car_admin.png',
        "assets/images/icon_suv_car.png"));
    sampleData.add(new RadioModel(
        false,
        "Moto",
        34,
        "assets/images/icon_motorcycle_admin.png",
        "assets/images/icon_motorcycle.png"));
    sampleData[0].isSelected = true;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      key: _scaffoldKey,
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, 65),
        child: AppBarWidget(_scaffoldKey, widget.usuario, false),) ,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            GradientBack(),
            bodyContainer(),
          ],
        ),
      ),
      drawer: widget.showDrawer ? DrawerPage(widget.usuario) : null,
    );
  }

  bodyContainer() => SingleChildScrollView(
        child: Column(
          children: <Widget>[
            headerContainerOptions(),
            carouselImage(),
            numeroDeFactura(),
            contenedorCamposFactura(),
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
        itemCount: sampleData.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            splashColor: Colors.white,
            onTap: () {
              setState(() {
                sampleData.forEach((element) => element.isSelected = false);
                sampleData[index].isSelected = true;
              });
            },
            child: RadioItem(sampleData[index]),
          );
        },
      );

  carouselImage() => Container(
        margin: EdgeInsets.only(top: 0),
        width: MediaQuery.of(context).size.width,
        height: 200,
        child: Stack(
          children: <Widget>[
            CarouselTest(),
            floatButtonAddImage(),
          ],
        ),
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

  contenedorCamposFactura() => Container(
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
            child: CamposFactura(),
          ),
        ),
      );

  floatButtonAddImage() => Align(
        alignment: Alignment(0.9, 0.9),
        child: FloatingActionButton(
          child: Icon(
            Icons.add,
            color: Colors.black,
            size: 30,
          ),
          backgroundColor: Colors.white,
          mini: true,
          elevation: 16,
          heroTag: null,
        ),
      );
}

class RadioModel {
  bool isSelected;
  final String text;
  final double withImage;
  final String imageSelected;
  final String imageUnselected;

  RadioModel(this.isSelected, this.text, this.withImage, this.imageSelected,
      this.imageUnselected);
}
