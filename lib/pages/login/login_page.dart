import 'package:flutter/material.dart';
import 'package:multiinventario/app_routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
                "lib/assets/imagenes/logoTienda.png",
                height: 150,
                width: 150,
              ),
              const SizedBox(height: 50),

              // Botón de confirmar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff2bbf55),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                },
                child: const Text("Confirmar"),
              ),

              // Botón de olvide mi pin
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffffde59),
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.loginInputEmail);
                },
                child: const Text("Olvidé mi PIN"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
