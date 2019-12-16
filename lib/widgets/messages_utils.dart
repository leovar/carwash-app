import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class MessagesUtils {
  static var alertStyle = AlertStyle(
    animationType: AnimationType.fromTop,
    isCloseButton: false,
    isOverlayTapDismiss: false,
    animationDuration: Duration(milliseconds: 400),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(13.0),
      side: BorderSide(
        color: Colors.grey,
      ),
    ),
    titleStyle: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w300,
      fontFamily: "Lato",
      fontSize: 22,
    ),
  );

  static Alert showAlert({
    @required BuildContext context,
    @required String title,
    AlertType alertType = AlertType.info,
  }) {
    return Alert(
      context: context,
      type: alertType,
      title: title,
      style: alertStyle,
      buttons: [
        DialogButton(
          color: Theme.of(context).accentColor,
          child: Text(
            'ACEPTAR',
            style: Theme.of(context).textTheme.button,
          ),
          onPressed: () => Navigator.of(context).pop(),
        )
      ],
    );
  }

  static Alert showAlertWithLoading({
    @required BuildContext context,
    @required String title,
  }) {
    return Alert(
      context: context,
      title: title,
      style: alertStyle,
      content: Center(
        child: CircularProgressIndicator(
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ),
      buttons: [],
    );
  }
}