import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FlutterToast {

  static void show({
    required String message,
    Color backgroundColor = Colors.black87,
    Color textColor = Colors.white,
    ToastGravity gravity = ToastGravity.BOTTOM,
  }) {

    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: gravity,
      backgroundColor: backgroundColor,
      textColor: textColor,
      fontSize: 14,
    );
  }

  /// Success Toast
  static void success(String message) {
    show(
      message: message,
      backgroundColor: Colors.green,
    );
  }

  /// Error Toast
  static void error(String message) {
    show(
      message: message,
      backgroundColor: Colors.red,
    );
  }

  /// Warning Toast
  static void warning(String message) {
    show(
      message: message,
      backgroundColor: Colors.orange,
    );
  }

}