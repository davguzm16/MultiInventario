// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ReportController {
  Future<String> generarPDF(pw.Document pdf, String filename) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File("${dir.path}/$filename");
      await file.writeAsBytes(await pdf.save());
      debugPrint('PDF generado en: ${file.path}');
      return file.path;
    } catch (e) {
      debugPrint('Error al generar PDF: $e');
      throw Exception('Error al generar PDF: $e');
    }
  }

  Future<void> mostrarPDF(BuildContext context, String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => _PDFViewerScreen(pdfPath: path),
          ),
        );
      } else {
        throw Exception('El archivo PDF no existe');
      }
    } catch (e) {
      debugPrint('Error al mostrar PDF: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al mostrar el PDF: $e')),
        );
      }
    }
  }
}

class _PDFViewerScreen extends StatefulWidget {
  final String pdfPath;
  const _PDFViewerScreen({required this.pdfPath});

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<_PDFViewerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Visor de PDF"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: sharePDF,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: downloadPDF,
          ),
        ],
      ),
      body: FutureBuilder<Uint8List>(
        future: File(widget.pdfPath).readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return PdfPreview(
              build: (format) => snapshot.data!,
              allowPrinting: false,
              allowSharing: false,
              canChangePageFormat: false,
              canChangeOrientation: false,
              maxPageWidth: MediaQuery.of(context).size.width * 0.9,
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar el PDF: ${snapshot.error}'),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Future<void> sharePDF() async {
    try {
      await Share.shareXFiles([XFile(widget.pdfPath)],
          text: "Aquí tienes el reporte en PDF");
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al compartir el PDF: $e')),
        );
      }
    }
  }

  Future<void> downloadPDF() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final newPath = "${directory.path}/reporte.pdf";
        final newFile = File(newPath);
        await newFile.writeAsBytes(await File(widget.pdfPath).readAsBytes());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("PDF guardado en: $newPath")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al descargar el PDF: $e')),
        );
      }
    }
  }
}
