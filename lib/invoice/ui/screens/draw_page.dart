import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class DrawPage extends StatefulWidget {
  final Function(bool) changeValueApproveData;
  final Function(Uint8List) callBackChargeImageFirm;
  final bool approveDataProcessing;

  DrawPage({
    Key key,
    this.changeValueApproveData,
    this.callBackChargeImageFirm,
    this.approveDataProcessing,
  });

  @override
  State<StatefulWidget> createState() => _DrawPage();
}

class _DrawPage extends State<DrawPage> {
  GlobalKey _globalKey = new GlobalKey();
  Color selectedColor = Colors.black;
  double opacity = 1.0;
  double strokeWidth = 3.0;
  bool _approveDataProcessing = false;
  List<DrawingPoints> points = List();
  StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.butt : StrokeCap.round;
  bool inside = false;
  Uint8List imageInMemory;

  @override
  void initState() {
    super.initState();
    _approveDataProcessing = widget.approveDataProcessing;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.done,
          color: Colors.white,
        ),
        onPressed: _capturePng,
      ),
      body: Stack(
        children: <Widget>[
          _containerImage(),
          RepaintBoundary(
            key: _globalKey,
            child: _drawerScreen(),
          ),
          _termsAndConditions(),
          _deleteImage(),
        ],
      ),
    );
  }

  Widget _containerImage() {
    return Container(
      margin: EdgeInsets.only(top: 30, left: 10, right: 10, bottom: 100),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.2,
          color: Color(0xFFAEAEAE),
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Widget _termsAndConditions() {
    return Container(
      margin: EdgeInsets.only(left: 10, right: 80, bottom: 20),
      alignment: Alignment.bottomLeft,
      child: Row(
        children: <Widget>[
          Checkbox(
            value: _approveDataProcessing,
            onChanged: (bool value) {
              setState(() {
                _approveDataProcessing = value;
                widget.changeValueApproveData(value);
              });
            },
            checkColor: Colors.white,
            activeColor: Color(0xFF59B258),
          ),
          Flexible(
            child: Text(
              "Aprueba Tratamiento de Datos Personales",
              style: TextStyle(
                fontFamily: "Lato",
                decoration: TextDecoration.none,
                color: Color(0xFFAEAEAE),
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerScreen() {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          RenderBox renderBox = context.findRenderObject();
          points.add(DrawingPoints(
              points: renderBox.globalToLocal(details.globalPosition),
              paint: Paint()
                ..strokeCap = strokeCap
                ..isAntiAlias = true
                ..color = selectedColor.withOpacity(opacity)
                ..strokeWidth = strokeWidth));
        });
      },
      onPanStart: (details) {
        setState(() {
          RenderBox renderBox = context.findRenderObject();
          points.add(DrawingPoints(
              points: renderBox.globalToLocal(details.globalPosition),
              paint: Paint()
                ..strokeCap = strokeCap
                ..isAntiAlias = true
                ..color = selectedColor.withOpacity(opacity)
                ..strokeWidth = strokeWidth));
        });
      },
      onPanEnd: (details) {
        setState(() {
          points.add(null);
        });
      },
      child: CustomPaint(
        size: Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height,
        ),
        painter: DrawingPainter(
          pointsList: points,
        ),
      ),
    );
  }

  Widget _deleteImage() {
    return Container(
      alignment: Alignment(0.9, 0.7),
      child: IconButton(
        icon: Icon(Icons.cancel),
        color: Theme.of(context).secondaryHeaderColor,
        iconSize: 35,
        onPressed: () {
          setState(() {
            points.clear();
          });
        },
      ),
    );
  }

  /// Functions

  Future<Uint8List> _capturePng() async {
    try {
      //print('inside');
      inside = true;
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
//      String bs64 = base64Encode(pngBytes);
//      print(pngBytes);
//      print(bs64);
      //print('png done');
      await widget.callBackChargeImageFirm(pngBytes);
      setState(() {
        imageInMemory = pngBytes;
        inside = false;
        Navigator.pop(context);
      });
      return pngBytes;
    } catch (e) {
      print(e);
    }
  }
}

class DrawingPainter extends CustomPainter {
  DrawingPainter({this.pointsList});

  List<DrawingPoints> pointsList;
  List<Offset> offsetPoints = List();

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,
            pointsList[i].paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points);
        offsetPoints.add(Offset(
            pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));
        canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class DrawingPoints {
  Paint paint;
  Offset points;

  DrawingPoints({this.points, this.paint});
}

enum SelectedMode { StrokeWidth, Opacity, Color }
