// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/models/credenciales.dart';
import 'package:pinput/pinput.dart';

class CodeEmailPage extends StatefulWidget {
  final String correctCode;
  final String emailUser;

  const CodeEmailPage(
      {super.key, required this.correctCode, required this.emailUser});

  @override
  _CodeEmailPageState createState() => _CodeEmailPageState();
}

class _CodeEmailPageState extends State<CodeEmailPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String inputCode = "";

  // Método para validar el código
  Future<void> validateCode() async {
    if (inputCode == widget.correctCode &&
        await Credenciales.crearCredencial("USER_EMAIL", widget.emailUser)) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.topSlide,
        title: "Correcto",
        desc: "¡El código es correcto!",
        btnOkOnPress: () {
          context.go('/login/create-pin', extra: false);
        },
        btnOkIcon: Icons.check_circle,
        btnOkColor: Colors.green,
      ).show();
    } else {
      AwesomeDialog(
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
