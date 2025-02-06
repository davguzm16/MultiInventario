// ignore_for_file: unrelated_type_equality_checks

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
  String? correctPIN;
  String? userPIN;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => obtenerCorrectPIN());
  }

  Future<void> obtenerCorrectPIN() async {
    try {
      correctPIN = await Credenciales.obtenerCredencial("USER_PIN");
      setState(() {});
      debugPrint("Correct pin: $correctPIN");
    } catch (e) {
      debugPrint("Error al obtener el USER_PIN: $e");
    }
  }

  @override
  void dispose() {
    pinController.dispose();
    super.dispose();
  }

  Future<void> _validarPin() async {
    if (userPIN == correctPIN) {
      context.go(
          '/home'); // Usamos go() en lugar de Navigator.pushReplacementNamed
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
                    return value == correctPIN
                        ? null
                        : 'El pin es incorrecto :c';
                  },
                  onCompleted: (value) {
                    userPIN = value;
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
                  onPressed: () =>
                      context.go('/login/code-email'), // Actualizado
                  child: const Text('Olvide mi Pin'),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () =>
                      context.go('/login/input-email'), // Actualizado
                  child: const Text('¿Eres nuevo? ¡Regístrate aquí!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
