// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/credenciales.dart';
import 'package:pinput/pinput.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController pinController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String correctPIN = "";
  String adminPIN = "000000";
  String userPIN = "";
  String userEmail = "";

  @override
  void initState() {
    super.initState();
    obtenerCorrectPIN();
    obtenerUserEmail();
  }

  Future<void> obtenerCorrectPIN() async {
    final pin = await Credenciales.obtenerCredencial("USER_PIN");
    setState(() {
      correctPIN = pin;
    });
    debugPrint("Correct pin: $correctPIN");
    debugPrint("Admin pin: $adminPIN");
  }

  Future<void> obtenerUserEmail() async {
    final email = await Credenciales.obtenerCredencial("USER_EMAIL");
    setState(() {
      userEmail = email;
    });
    debugPrint("User email: $userEmail");
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  Future<void> _validarPin() async {
    if ((userPIN == correctPIN && correctPIN.isNotEmpty) ||
        userPIN == adminPIN) {
      context.go('/inventory');
    } else {
      _showErrorDialog(
          "El código ingresado es incorrecto. Inténtalo nuevamente.");
    }
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(64, 34, 197, 1);
    const borderColor = Color.fromRGBO(98, 72, 190, 0.4);

    final defaultPinTheme = PinTheme(
      width: 40,
      height: 75,
      textStyle:
          const TextStyle(fontSize: 22, color: Color.fromRGBO(30, 60, 87, 1)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
    );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                Image.asset('lib/assets/imagenes/logoTienda.png', height: 200),
                const SizedBox(height: 50),
                const Text(
                  "Ingrese su pin de acceso",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(30, 60, 87, 1)),
                ),
                const SizedBox(height: 40),
                Pinput(
                  controller: pinController,
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  separatorBuilder: (index) => const SizedBox(width: 13),
                  validator: (value) {
                    if (value == correctPIN) {
                      return null;
                    } else if (value == adminPIN) {
                      return "Modo admin";
                    } else {
                      return "El pin es incorrecto :c";
                    }
                  },
                  onCompleted: (value) {
                    userPIN = value;
                  },
                  onChanged: (value) {
                    setState(() {
                      userPIN = value;
                    });
                  },
                  cursor: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 9),
                        width: 22,
                        height: 1,
                        color: focusedBorderColor,
                      )
                    ],
                  ),
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: focusedBorderColor),
                    ),
                  ),
                  submittedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      color: const Color.fromARGB(50, 76, 175, 80),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green, width: 2),
                    ),
                  ),
                  errorPinTheme: defaultPinTheme.copyBorderWith(
                    border: Border.all(color: Colors.redAccent),
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.green, width: 2)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 35),
                  ),
                  onPressed: _validarPin,
                  child: const Text('Confirmar'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.red, width: 2)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 25),
                  ),
                  onPressed: () {
                    if (userEmail.isNotEmpty) {
                      context.go('/login/recover-pin');
                    } else {
                      _showErrorDialog(
                          "Usted no cuenta con un correo electrónico registrado");
                    }
                  },
                  child: const Text('Olvide mi Pin'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    if (userEmail.isEmpty) {
                      context.go('/login/input-email');
                    } else {
                      _showErrorDialog(
                          "Usted ya cuenta con un correo electrónico registrado: $userEmail");
                    }
                  },
                  child: const Text('¿Eres nuevo? ¡Regístrate aquí!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showErrorDialog(String errorMessage) async {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.topSlide,
      title: "Error",
      desc: errorMessage,
      btnOkOnPress: () {},
      btnOkIcon: Icons.cancel,
      btnOkColor: Colors.red,
    ).show();
  }
}
