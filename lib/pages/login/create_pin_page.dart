import 'package:flutter/material.dart';
import 'package:multiinventario/app_routes.dart';
import 'package:pinput/pinput.dart';

class CreatePinPage extends StatefulWidget {
  const CreatePinPage({super.key});

  @override
  _CreatePinPageState createState() => _CreatePinPageState();
}

class _CreatePinPageState extends State<CreatePinPage> {
  String pin = "";
  String confirmPin = "";

  void validatePin() {
    if (pin == confirmPin && pin.length == 6) {
      Navigator.pushNamed(context, AppRoutes.login);
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text(
              "Los PIN ingresados no coinciden o no tienen 6 dígitos."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            Image.asset(
              'lib/assets/imagenes/logoTienda.png',
              height: 200,
            ),
            const SizedBox(height: 50),
            const Text(
              "Crea un PIN de 6 dígitos para asegurar tu cuenta",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Pinput(
              length: 6,
              onChanged: (value) => pin = value,
              obscureText: true,
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
                      Border.all(color: const Color.fromARGB(255, 87, 31, 192)),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Vuelve a ingresar el PIN para confirmar",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Pinput(
              length: 6,
              onChanged: (value) => confirmPin = value,
              obscureText: true,
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
                      Border.all(color: const Color.fromARGB(255, 87, 31, 192)),
                ),
              ),
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
              onPressed: validatePin,
              child: const Text(
                "Confirmar PIN",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
