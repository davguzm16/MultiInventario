import 'package:awesome_dialog/awesome_dialog.dart';

class ConfirmDialog extends AwesomeDialog {
  ConfirmDialog(
      {required super.context,
      required String message,
      required String title,
      void Function()? btnOkOnPress})
      : super(
          dialogType: DialogType.info,
          animType: AnimType.topSlide,
          title: title,
          desc: message,
          btnOkOnPress: btnOkOnPress ?? () {},
          btnCancelOnPress: () {},
        ) {
    show();
  }
}
