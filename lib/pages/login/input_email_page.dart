import 'package:flutter/material.dart';
import 'package:multiinventario/app_routes.dart';

class InputEmailPage extends StatefulWidget {
  const InputEmailPage({super.key});

  @override
  State<InputEmailPage> createState() => _InputEmailPageState();
}

class _InputEmailPageState extends State<InputEmailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Input Email Page"),

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
                Navigator.pushNamed(context, AppRoutes.loginCodeEmail);
              },
              child: const Text("Confirmar"),
            ),
          ],
        ),
      ),
    );
  }
}
