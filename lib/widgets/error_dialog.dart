import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class ErrorDialog extends AwesomeDialog {
  ErrorDialog({
    required super.context,
    required String errorMessage,
    dynamic Function()? okOnPress,
  }) : super(
          dialogType: DialogType.error,
          animType: AnimType.topSlide,
          title: "Error",
          desc: errorMessage,
          btnOkOnPress: okOnPress ?? () {},
          btnOkIcon: Icons.cancel,
          btnOkColor: Colors.red,
        ) {
    show();
  }
}
