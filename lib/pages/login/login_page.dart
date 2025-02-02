import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController pinController;
  late final FocusNode focusNode;
  late final GlobalKey<FormState> formKey;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    pinController = TextEditingController();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Color del cuadro lleno
    const focusedBoderColor = Color.fromRGBO(64, 34, 197, 1);
    //Color de letra
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    //Color del cuadro vacío
    const borderColor = Color.fromRGBO(98, 72, 190, 0.4);

    final defaultPinTheme = PinTheme(
      width: 40,
      height: 75,
      textStyle: const TextStyle(
        fontSize: 22,
        color: Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                Image.asset(
                  'lib/assets/imagenes/logoTienda.png',
                  height: 200,
                ),
                const SizedBox(height: 50),
                const Text(
                  "Ingrese su pin de acceso",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(30, 60, 87, 1),
                  ),
                ),
                const SizedBox(height: 40),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Pinput(
                    controller: pinController,
                    focusNode: focusNode,
                    length: 6,
                    defaultPinTheme: defaultPinTheme,
                    separatorBuilder: (index) => const SizedBox(width: 13),
                    validator: (value) {
                      return value == '123456'
                          ? null
                          : 'El pin es incorrecto :c';
                    },
                    hapticFeedbackType: HapticFeedbackType.lightImpact,
                    onCompleted: (pin) {
                      log(pin);
                    },
                    onChanged: (value) {
                      log(value);
                    },
                    cursor: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 9),
                          width: 22,
                          height: 1,
                          color: focusedBoderColor,
                        )
                      ],
                    ),
                    focusedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: focusedBoderColor),
                      ),
                    ),
                    submittedPinTheme: defaultPinTheme.copyWith(
                      decoration: defaultPinTheme.decoration!.copyWith(
                        color: fillColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: focusedBoderColor),
                      ),
                    ),
                    errorPinTheme: defaultPinTheme.copyBorderWith(
                      border: Border.all(color: Colors.redAccent),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (states) {
                        if (states.contains(WidgetState.pressed)) {
                          return Colors.greenAccent;
                        }
                        return Colors.green;
                      },
                    ),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Colors.green, width: 2),
                      ),
                    ),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 35),
                    ),
                  ),
                  onPressed: () {
                    focusNode.unfocus();
                    formKey.currentState!.validate();
                  },
                  child: const Text('Confirmar'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>(
                      (states) {
                        if (states.contains(WidgetState.pressed)) {
                          return Colors.redAccent;
                        }
                        return const Color.fromARGB(255, 228, 15, 15);
                      },
                    ),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 255, 0, 0),
                          width: 2,
                        ),
                      ),
                    ),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, "/login/code-email");
                    formKey.currentState!.validate();
                  },
                  child: const Text('Olvide mi Pin'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/login/input-email");
                    focusNode.unfocus();
                    formKey.currentState!.validate();
                  },
                  child: const Text('¿Eres nuevo? ¡Regístrate aquí!'),
                ),
                const SizedBox(height: 20), // Espaciado final
              ],
            ),
          ),
        ),
      ),
    );
  }
}
