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

  void showResultDialog(bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 60,
              ),
              const SizedBox(height: 10),
              Text(
                isSuccess ? "¡Excelente!" : "¡Ha ocurrido un error!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isSuccess
                    ? "Se ha confirmado el código de verificación"
                    : "No se pudo confirmar el código de verificación",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSuccess ? Colors.green : Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Cierra el diálogo
                  if (isSuccess) {
                    navigateToNextScreen(); // Navegación si es correcto
                  }
                },
                child: Text(
                  isSuccess ? "Continuar" : "Cerrar",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void validateCode() {
    if (enteredCode == correctCode) {
      Navigator.pushReplacementNamed(context, "/login/create-pin");
    } else {
      showResultDialog(false); // Código incorrecto
    }
  }

  void navigateToNextScreen() {
    // Aquí defines la navegación a la siguiente ventana
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NextScreen(), // Cambia a tu próxima pantalla
      ),
    );
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

class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pantalla de Confirmación"),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward), // Ícono para navegar
            onPressed: () {
              Navigator.pushNamed(context, "/login/create-pin");
            },
          ),
        ],
      ),
      body: const Center(
        child: Text("¡Has llegado a la próxima pantalla!"),
      ),
    );
  }
}
