import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InfoHeaderContainer extends StatelessWidget {
  final String image;
  final String textInfo;

  InfoHeaderContainer({Key key, this.image, this.textInfo = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: EdgeInsets.only(left: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(right: 15),
            child: Image(
              width: 30,
              image: AssetImage(image),
            ),
          ),
          textInfo.isEmpty
              ? null
              : Text(
                  textInfo, //- No. 1017
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
  }
}
