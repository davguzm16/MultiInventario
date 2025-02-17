import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  String? _barcode;

  @override
  void dispose() {
    MobileScannerController().dispose();
    super.dispose();
  }

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
          if (_barcode == null)
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
        visible: _barcode != null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton(
              heroTag: 'btnAceptar',
              onPressed: () {
                if (_barcode != null) {
                  context.pop(_barcode);
                }
              },
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              child: const Icon(Icons.check),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              heroTag: 'btnCancelar',
              onPressed: () {
                setState(() {
                  _barcode = null;
                });
              },
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              child: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
