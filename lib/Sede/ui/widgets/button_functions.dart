import 'package:flutter/material.dart';

class ButtonFunctions extends StatefulWidget {

  String buttonName = "";
  String imageAsset = "";

  ButtonFunctions(this.buttonName, this.imageAsset);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ButtonFunctions();
  }
}

class _ButtonFunctions extends State<ButtonFunctions> {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Material(
        child: InkWell(
          onTap: () => print('hello'),
          child: Container(
            height: 70.0,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      widget.buttonName,
                      style: TextStyle(
                        fontFamily: "Lato",
                        fontWeight: FontWeight.bold,
                        fontSize: 21,
                        color: Color(0XFF27AEBB),
                      ),
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      child: Ink.image(
                        image: AssetImage(
                            widget.imageAsset),
                        width: 30,
                        alignment: Alignment.centerRight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        color: Colors.transparent,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7.0),
      ),
    );
  }

}
