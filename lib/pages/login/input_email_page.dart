// ignore_for_file: use_build_context_synchronously

import 'dart:math';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mailer/mailer.dart';
import 'package:multiinventario/controllers/credenciales.dart';
import 'package:go_router/go_router.dart';

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
  late final GlobalKey<FormState> formKey;

  bool isSendingEmail = false;

  String generarCodigoVerificacion() {
    Random random = Random();
    return (random.nextInt(900000) + 100000).toString();
  }

  Future<void> enviarCodigoEmail() async {
    setState(() {
      isSendingEmail = true;
    });

    String? addressSendEmail =
        await Credenciales.obtenerCredencial("ADDRESS_SEND_EMAIL");
    String? passwordSendEmail =
        await Credenciales.obtenerCredencial("PASSWORD_SEND_EMAIL");

    if (addressSendEmail.isEmpty || passwordSendEmail.isEmpty) {
      setState(() {
        isSendingEmail = false;
      });
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.topSlide,
        title: "Error",
        desc:
            "No se han encontrado las credenciales de correo electrónico de MultiInventario, contactar con el administrador.",
        btnOkOnPress: () {},
        btnOkIcon: Icons.cancel,
        btnOkColor: Colors.red,
      ).show();
      return;
    }

    final String codigo = generarCodigoVerificacion();

    try {
      final smtpServer = gmail(addressSendEmail, passwordSendEmail);
      final message = Message()
        ..from = Address(addressSendEmail)
        ..recipients.add(emailController.text)
        ..subject = 'Código de verificación'
        ..text = 'Tu código de verificación es: $codigo';

      await send(message, smtpServer);

      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.topSlide,
          title: "Correcto",
          desc:
              "El código se ha enviado a su correo ${emailController.text} correctamente!",
          btnOkOnPress: () {
            FocusScope.of(context).requestFocus(FocusNode());
            context.go('/login/code-email', extra: codigo);
          },
          btnOkIcon: Icons.check_circle,
          btnOkColor: Colors.green,
        ).show();
      }
    } on MailerException catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.topSlide,
          title: "Error",
          desc: "Hubo un fallo al enviar el código de verificación.\n$e",
          btnOkOnPress: () {},
          btnOkIcon: Icons.cancel,
          btnOkColor: Colors.red,
        ).show();
      }
    } finally {
      if (mounted) {
        setState(() {
          isSendingEmail = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const focusedBoderColor = Color.fromRGBO(64, 34, 197, 1);
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
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Ingrese su correo',
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
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese su correo';
                }
                final emailRegex =
                    RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                if (!emailRegex.hasMatch(value)) {
                  return 'Ingrese un correo válido';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 30),
          isSendingEmail
              ? SizedBox(
                  width: 150,
                  child: LinearProgressIndicator(),
                )
              : ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.resolveWith<Color>((states) {
                      if (states.contains(WidgetState.pressed)) {
                        return Colors.greenAccent;
                      }
                      return Colors.green;
                    }),
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
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    await Future.delayed(const Duration(milliseconds: 100));
                    if (formKey.currentState!.validate()) {
                      enviarCodigoEmail();
                    }
                  },
                  child: const Text('Confirmar'),
                ),
        ],
      ),
    );
  }
}
