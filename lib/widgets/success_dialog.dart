import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class SuccessDialog extends AwesomeDialog {
  SuccessDialog({
    required super.context,
    required String successMessage,
    void Function()? btnOkOnPress,
  }) : super(
          dialogType: DialogType.success,
          animType: AnimType.topSlide,
          title: "Éxito",
          desc: successMessage,
          btnOkOnPress: btnOkOnPress ?? () {},
          btnOkIcon: Icons.check_circle,
          btnOkColor: Colors.green,
        ) {
    show();
  }
}
