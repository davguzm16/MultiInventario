import 'package:flutter/material.dart';

class CodeEmailPage extends StatefulWidget {
  const CodeEmailPage({super.key});

  @override
  State<CodeEmailPage> createState() => _CodeEmailPageState();
}

class _CodeEmailPageState extends State<CodeEmailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Code Email Page"),
          ],
        ),
      ),
    );
  }
}
