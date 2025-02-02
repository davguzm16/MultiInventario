import 'package:flutter/material.dart';
import 'package:multiinventario/app_routes.dart';
import 'package:multiinventario/pages/login/login_page.dart';

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
//Fondo
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: AppRoutes.routes,
      home: LoginPage(),
    );
  }
}
