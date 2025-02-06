// ignore_for_file: sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  String? _barcode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner'),
        centerTitle: true,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            onDetect: (barcode) {
              setState(() {
                _barcode = barcode.barcodes.isNotEmpty
                    ? barcode.barcodes.first.rawValue
                    : 'Error al escanear';
              });
            },
          ),
          // Cuadrado grande SOLO si no se ha detectado un código
          if (_barcode == null)
            Container(
              width: 300, // Ancho del cuadrado grande
              height: 300, // Alto del cuadrado grande
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          // Mensaje centrado después de escanear
          if (_barcode != null)
            Center(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  'Código escaneado: $_barcode',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Visibility(
        visible: _barcode != null, // Solo muestra los botones si hay código
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              onPressed: () {
                if (_barcode != null && _barcode!.length == 13) {
                  Navigator.pop(context, _barcode);
                }
              },
              child: const Icon(Icons.check),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _barcode = null; // Reinicia el código escaneado
                });
              },
              child: const Icon(Icons.close),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
