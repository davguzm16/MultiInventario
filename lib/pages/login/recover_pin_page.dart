// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:math';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:multiinventario/controllers/credenciales.dart';
import 'package:pinput/pinput.dart';

class RecoverPinPage extends StatefulWidget {
  const RecoverPinPage({super.key});

  @override
  _RecoverPinPageState createState() => _RecoverPinPageState();
}

class _RecoverPinPageState extends State<RecoverPinPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String inputCode = "";
  String codigo = "";

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      if (mounted) {
        enviarCodigoEmail();
      }
    });
  }

  String generarCodigoVerificacion() {
    Random random = Random();
    return (random.nextInt(900000) + 100000).toString();
  }

  Future<void> enviarCodigoEmail() async {
    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C10BB)),
                strokeWidth: 3.5,
              ),
              SizedBox(height: 20),
              Text(
                "Enviando código...",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3C57),
                ),
              ),
              SizedBox(height: 5),
              Text(
                "Por favor, espere un momento",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        );
      },
    );

    String? addressSendEmail =
        await Credenciales.obtenerCredencial("ADDRESS_SEND_EMAIL");
    String? passwordSendEmail =
        await Credenciales.obtenerCredencial("PASSWORD_SEND_EMAIL");

    if (addressSendEmail.isEmpty || passwordSendEmail.isEmpty) {
      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.topSlide,
          title: "Error",
          desc:
              "No se han encontrado las credenciales de correo electrónico de MultiInventario, contactar con el administrador.",
          btnOkOnPress: () {},
          btnOkIcon: Icons.cancel,
          btnOkColor: Colors.red,
        ).show();
      }
      return;
    }

    codigo = generarCodigoVerificacion();
    final String userEmail = await Credenciales.obtenerCredencial("USER_EMAIL");

    try {
      final smtpServer = gmail(addressSendEmail, passwordSendEmail);
      final message = Message()
        ..from = Address(addressSendEmail)
        ..recipients.add(userEmail)
        ..subject = 'Código de verificación'
        ..text = 'Tu código de verificación es: $codigo';

      await send(message, smtpServer);

      if (mounted) {
        Navigator.pop(context);
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.topSlide,
          title: "Correcto",
          desc: "El código se ha enviado a su correo $userEmail correctamente!",
          btnOkOnPress: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          btnOkIcon: Icons.check_circle,
          btnOkColor: Colors.green,
        ).show();
      }
    } on MailerException catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.topSlide,
          title: "Error",
          desc: "Hubo un fallo al enviar el código de verificación.\n$e",
          btnOkOnPress: () {},
          btnOkIcon: Icons.cancel,
          btnOkColor: Colors.red,
        ).show();
      }
    }
  }

  // Método para validar el código
  Future<void> validateCode() async {
    if (inputCode == codigo) {
      await AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.topSlide,
        title: "Correcto",
        desc: "¡El código es correcto!",
        btnOkOnPress: () {
          context.go('/login/create-pin', extra: true);
        },
        btnOkIcon: Icons.check_circle,
        btnOkColor: Colors.green,
      ).show();
    } else {
      await AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        title: "Error",
        desc: "El código ingresado es incorrecto. Inténtalo nuevamente.",
        btnOkOnPress: () {},
        btnOkIcon: Icons.cancel,
        btnOkColor: Colors.red,
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Confirmar Código",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color.fromRGBO(30, 60, 87, 1),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/assets/imagenes/logoTienda.png',
                      height: 150,
                      width: 150,
                    ),
                    const SizedBox(height: 30),
                    const Text(
                      "Se le ha enviado un código a su correo",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(30, 60, 87, 1),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 280,
                      child: Pinput(
                        length: 6,
                        defaultPinTheme: PinTheme(
                          width: 50,
                          height: 70,
                          textStyle: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: const Color.fromARGB(255, 76, 16, 187)),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 50,
                          height: 70,
                          textStyle: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color:
                                    const Color.fromARGB(255, 121, 100, 180)),
                          ),
                        ),
                        onChanged: (value) {
                          inputCode = value;
                        },
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Debe ingresar los 6 dígitos del código';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          validateCode();
                        }
                      },
                      child: const Text(
                        "Confirmar",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
