import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'dart:async';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ReportController  {
  Future<String> generarPDF(pw.Document pdf, String filename) async {
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/$filename");
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  Future<void> mostrarPDF(BuildContext context,String path) async {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => verPDFScreen(path)),
    );
  }
  Widget verPDFScreen(String pdfPath) {
    return _PDFViewerScreen(pdfPath: pdfPath);
  }

}

class _PDFViewerScreen extends StatefulWidget {
  final String pdfPath;
  const _PDFViewerScreen({Key? key, required this.pdfPath}) : super(key: key);

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<_PDFViewerScreen> {
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();
  bool isReady = false;

  Future<void> sharePDF() async {
    await Share.shareFiles([widget.pdfPath], text: "Aquí tienes el reporte en PDF");
  }

  Future<void> downloadPDF() async {
    final directory = await getExternalStorageDirectory();
    if (directory != null) {
      final newPath = "${directory.path}/reporte_ventas.pdf";
      final newFile = File(newPath);
      await newFile.writeAsBytes(await File(widget.pdfPath).readAsBytes());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("PDF guardado en: $newPath")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reporte"),
        actions: [
          IconButton(icon: Icon(Icons.download), onPressed: downloadPDF),
          IconButton(icon: Icon(Icons.share), onPressed: sharePDF),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.pdfPath,
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
              setState(() {});
              Future.delayed(Duration(milliseconds: 300), () async {
                pdfViewController.setPage(0);
              });
            },
            onRender: (_) {
              setState(() => isReady = true);
            },
            onError: (error) {
              print("Error al cargar PDF: $error");
              setState(() => isReady = true);
            },
          ),
          if (!isReady) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}