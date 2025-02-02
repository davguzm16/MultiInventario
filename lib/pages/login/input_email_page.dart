import 'package:flutter/material.dart';
import 'package:multiinventario/app_routes.dart';

class InputEmailPage extends StatelessWidget {
  const InputEmailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const FractionallySizedBox(
        widthFactor: 1,
        child: PinputInfo(),
      ),
    );
  }
}

class PinputInfo extends StatefulWidget {
  const PinputInfo({super.key});

  @override
  State<PinputInfo> createState() => _PinputInfoState();
}

class _PinputInfoState extends State<PinputInfo> {
  late final TextEditingController emailController;
  late final FocusNode focusNode;
  late final GlobalKey<FormState> formKey;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    emailController = TextEditingController();
    focusNode = FocusNode();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Color del cuadro lleno
    const focusedBoderColor = Color.fromRGBO(64, 34, 197, 1);
    //Color de letra
    //Color del cuadro vacío
    const borderColor = Color.fromRGBO(98, 72, 190, 0.4);

    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'lib/assets/imagenes/logoTienda.png',
            height: 200,
          ),
          const SizedBox(height: 50),
          const Text(
            "Ingrese su correo electrónico",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(30, 60, 87, 1),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: ' ',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 20,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderColor),
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: focusedBoderColor),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.greenAccent; //Color al presionar
                }
                return Colors.green; //Color normal :D
              }),
              foregroundColor:
                  WidgetStateProperty.all(Colors.white), //Color del texto
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
              Navigator.pushNamed(context, AppRoutes.loginCodeEmail);
              focusNode.unfocus();
              formKey.currentState!.validate();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
