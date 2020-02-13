import 'dart:io';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

final Widget placeholder = Container(color: Colors.grey);

class CarouselCarsWidget extends StatefulWidget {
  List<String> imgList = [];
  final editForm;
  final Function(String) callbackDeleteImage;

  CarouselCarsWidget(
      {Key key, @required this.callbackDeleteImage, this.imgList, this.editForm})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _CarouselCarsWidget();
  }
}

class _CarouselCarsWidget extends State<CarouselCarsWidget> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return widget.imgList.length != null && widget.imgList.length > 0
        ? carouselCars()
        : placeholder();
  }

  placeholder() => Container(
    child: Image.asset("assets/images/background_ph_image.png",
      width: MediaQuery.of(context).size.width,
      fit: BoxFit.cover,
    ),
  );

  carouselCars() {
    return CarouselSlider(
      height: 400,
      items: rows(),
      autoPlay: false,
      enlargeCenterPage: true,
      viewportFraction: 1.0,
      enableInfiniteScroll: false,
      initialPage: 0,
      onPageChanged: (index) {
        setState(() {
          _current = index;
        });
      },
    );
  }

  rows() {
    return map<Widget>(
      widget.imgList,
      (index, i) {
        return Container(
          //margin: EdgeInsets.only(left: 5.0, right: 5.0),
          child: ClipRRect(
            //borderRadius: BorderRadius.all(Radius.circular(5.0)),
            child: Stack(children: <Widget>[
              _getImageProvider(i),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(200, 0, 0, 0),
                        Color.fromARGB(0, 0, 0, 0)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Text(
                    '${index + 1} de ${widget.imgList.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 18,
                child: Center(
                  child: Container(
                    width: 37,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          Color.fromARGB(200, 0, 0, 0),
                          Color.fromARGB(0, 0, 0, 0)
                        ],
                      ),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.only(right: 1),
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      iconSize: 28,
                      onPressed: widget.editForm ? () {
                        setState(() {
                          widget.callbackDeleteImage(i);
                        });
                      } : null,
                    ),
                  ),
                ),
              ),
            ]),
          ),
        );
      },
    ).toList();
  }

  Widget _getImageProvider(String imagePath){
    if (imagePath.isNotEmpty &&
        imagePath.contains('https://firebasestorage.')) {
      return Image.network(imagePath, width: 1000.0, fit: BoxFit.cover,);
    } else if (imagePath.isNotEmpty) {
      return Image.file(
        File(imagePath),
        width: 1000.0,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset("assets/images/background_ph_image.png",
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      );
    }
  }

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }
}
