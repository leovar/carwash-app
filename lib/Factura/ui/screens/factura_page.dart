import 'package:car_wash_app/Factura/ui/widgets/carousel_test.dart' as prefix0;
import 'package:car_wash_app/User/model/user.dart';
import 'package:car_wash_app/widgets/header_menu_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:car_wash_app/widgets/drawer_page.dart';
import 'package:car_wash_app/widgets/gradient_back.dart';
import 'package:car_wash_app/Factura/ui/widgets/radio_item.dart';
import 'package:car_wash_app/Factura/ui/widgets/carousel_test.dart';

class FacturaPage extends StatefulWidget {
  final User usuario;

  FacturaPage(this.usuario);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _FacturaPage();
  }
}

class _FacturaPage extends State<FacturaPage> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  List<RadioModel> sampleData = new List<RadioModel>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    sampleData.add(new RadioModel(false, "Auto", 38, "assets/images/icon_car_admin.png", "assets/images/icon_car.png"));
    sampleData.add(new RadioModel(false, "Camioneta", 37, 'assets/images/icon_suv_car_admin.png', "assets/images/icon_suv_car.png"));
    sampleData.add(new RadioModel(false, "Moto", 34, "assets/images/icon_motorcycle_admin.png", "assets/images/icon_motorcycle.png"));
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
      appBar: AppBar(
        flexibleSpace: Container(
          color: Colors.white,
        ),
        //HeaderMenuPage(_scaffoldKey, widget.usuario),
        leading: Container(),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            GradientBack(),
            bodyContainer(),
          ],
        ),
      ),
      drawer: Container(color: Colors.white), //DrawerPage(widget.usuario),
    );
  }

  bodyContainer() => Column(
        children: <Widget>[
          headerContainerOptions(),
          carouselImage(),
        ],
      );

  headerContainerOptions() => Container(
    height: 45,
    decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        boxShadow: [BoxShadow(
          color: Colors.grey,
          blurRadius: 5.0,
        ),]
    ),
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
      child: CarouselTest()
  );

}

class RadioModel {
  bool isSelected;
  final String text;
  final double withImage;
  final String imageSelected;
  final String imageUnselected;

  RadioModel(this.isSelected, this.text, this.withImage, this.imageSelected, this.imageUnselected);
}
