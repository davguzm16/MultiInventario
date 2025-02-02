import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

class CodeEmailPage extends StatelessWidget {
  const CodeEmailPage({super.key});

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
      body: const CodeVerification(),
    );
  }
}

class CodeVerification extends StatefulWidget {
  const CodeVerification({super.key});

  @override
  State<CodeVerification> createState() => _CodeVerificationState();
}

class _CodeVerificationState extends State<CodeVerification> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final String correctCode = "123456"; // Código correcto para la validación
  String enteredCode = ""; // Variable para almacenar el código ingresado

  Future<void> validateCode() async {
    if (enteredCode == correctCode) {
      await AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.topSlide,
        title: "Correcto",
        desc: "¡El código es correcto!",
        btnOkOnPress: () {},
        btnOkIcon: Icons.check_circle,
        btnOkColor: Colors.green,
      ).show();

      Navigator.pushReplacementNamed(context, "/login/create-pin");
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
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'lib/assets/imagenes/logoTienda.png',
              height: 200,
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
            Pinput(
              length: 6, // Longitud del código
              defaultPinTheme: PinTheme(
                width: 40,
                height: 75,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: const Color.fromARGB(255, 76, 16, 187)),
                ),
              ),
              focusedPinTheme: PinTheme(
                width: 40,
                height: 75,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: const Color.fromARGB(255, 121, 100, 180)),
                ),
              ),
              onChanged: (value) {
                enteredCode = value; // Actualiza el código ingresado
              },
              validator: (value) {
                if (value == null || value.length < 6) {
                  return 'Debe ingresar los 6 dígitos del código';
                }
                return null;
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: validateCode,
              child: const Text(
                "Confirmar",
                style: TextStyle(color: Colors.white), // Texto en blanco
              ),
            ),
          ],
        ),
      ),
    );
  }
}
