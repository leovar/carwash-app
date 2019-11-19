import 'package:flutter/material.dart';


class AppBarTextWidget extends StatelessWidget {
  final String textAppBar;

  AppBarTextWidget({Key key, this.textAppBar});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        iconSize: 30,
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        textAppBar,
        style: TextStyle(
          fontFamily: "Lato",
          decoration: TextDecoration.none,
          fontWeight: FontWeight.w600,
          color: Colors.black,
          fontSize: 24,
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

}
