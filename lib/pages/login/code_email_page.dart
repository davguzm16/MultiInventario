import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart'; // Importa AwesomeDialog

class CodeEmailPage extends StatefulWidget {
  const CodeEmailPage({super.key});

  @override
  State<CodeEmailPage> createState() => _CodeEmailPageState();
}

class _CodeEmailPageState extends State<CodeEmailPage> {
  // Controladores para las casillas de texto
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());

  // Focus nodes para controlar el foco entre los campos
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  // Función para verificar el código
  void _verifyCode() {
    // Unir los valores de los 6 TextFields en un solo string
    String enteredCode = _controllers.map((controller) => controller.text).join();

    // Verificar si el código es el correcto
    if (enteredCode == "111111") {
      // Mostrar un mensaje de éxito si el código es correcto
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.topSlide,
        title: "Correcto",
        desc: "¡El código es correcto!",
        btnOkOnPress: () {},
        btnOkIcon: Icons.check_circle,
        btnOkColor: Colors.green,
      ).show();
    } else {
      // Mostrar un mensaje de error si el código es incorrecto
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
      backgroundColor: Colors.blueGrey.shade50,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Imagen logo
              Image.asset(
                "lib/assets/imagenes/logoTienda.png", // Ruta de tu logo
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 50), // Espacio entre el logo y las casillas de texto

              // Título
              Text(
                "Ingrese el código de 6 dígitos",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              // Casillas de texto para el código
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    width: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                      onChanged: (value) {
                        // Si el valor es no vacío y no es el último campo, mueve al siguiente
                        if (value.isNotEmpty && index < 5) {
                          FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 50),

              // Botón de confirmar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff2bbf55),
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _verifyCode, // Llamamos a la función de verificación
                child: const Text("Confirmar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
