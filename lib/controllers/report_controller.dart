import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:multiinventario/helpers/database_helper.dart'; // Añade esta línea

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

  Future<void> mostrarPDF(BuildContext context, String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        Navigator.push(
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

  Future<void> generarReporteProductosVendidos(
      BuildContext context, DateTime fechaInicio, DateTime fechaFin) async {
    try {
      // Formatea las fechas correctamente para SQLite
      String fechaInicioStr = fechaInicio.toIso8601String().split('T')[0];
      String fechaFinStr = fechaFin.toIso8601String().split('T')[0];

      // Añade esta línea antes de ejecutar la consulta
      await verificarBaseDatos();

      // Modifica la consulta SQL para usar las fechas formateadas
      final sql = '''
        SELECT 
          p.codigo,
          p.nombre as producto,
          SUM(dv.cantidad) as cantidad_total,
          p.precioVenta as precio_unidad,
          SUM(dv.descuento) as descuento_total,
          SUM(dv.subtotal) as total_ventas,
          SUM(dv.subtotal - (dv.cantidad * p.precioCompra)) as ganancias
        FROM DetalleVenta dv
        JOIN Venta v ON dv.idVenta = v.idVenta
        JOIN Producto p ON dv.idProducto = p.idProducto
        WHERE date(v.fecha) BETWEEN date(?) AND date(?)
        GROUP BY p.idProducto, p.codigo, p.nombre, p.precioVenta
        ORDER BY cantidad_total DESC
      ''';

      // Depuración de la consulta
      debugPrint('Fechas de consulta:');
      debugPrint('Fecha inicio: $fechaInicioStr');
      debugPrint('Fecha fin: $fechaFinStr');

      // Obtener los resultados de la base de datos
      final db = await DatabaseHelper.instance.database;
      final results = await db.rawQuery(sql, [fechaInicioStr, fechaFinStr]);

      // Debug: Imprime la consulta SQL y los parámetros
      debugPrint('Consulta SQL: $sql');
      debugPrint('Parámetros: [$fechaInicioStr, $fechaFinStr]');
      debugPrint('Resultados: $results');

      // Añade estos logs de depuración
      debugPrint('Contenido de results:');
      for (var row in results) {
        debugPrint('Fila: $row');
      }

      // Verifica si hay resultados
      if (results.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('No hay ventas registradas en el período seleccionado'),
            ),
          );
        }
        return; // Salir del método si no hay datos
      }

      // Debug: Imprime los resultados para verificar
      debugPrint('Resultados encontrados: ${results.length}');
      debugPrint('Primer resultado: ${results.first}');

      // Crear el documento PDF
      final pdf = pw.Document();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return [
              pw.Header(
                level: 0,
                child: pw.Text('Reporte de Productos Vendidos',
                    style: pw.TextStyle(
                        fontSize: 20, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Período: ${fechaInicio.day}/${fechaInicio.month}/${fechaInicio.year} - ${fechaFin.day}/${fechaFin.month}/${fechaFin.year}',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  'Ranking',
                  'Código',
                  'Producto',
                  'Cantidad Total',
                  'Precio Unitario',
                  'Descuento Total',
                  'Total Ventas',
                  'Ganancias'
                ],
                data: List<List<String>>.generate(
                  results.length,
                  (index) => [
                    '${index + 1}',
                    results[index]['codigo']?.toString() ?? '',
                    results[index]['producto']?.toString() ?? '',
                    results[index]['cantidad_total']?.toString() ?? '0',
                    'S/. ${(results[index]['precio_unidad'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                    'S/. ${(results[index]['descuento_total'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                    'S/. ${(results[index]['total_ventas'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                    'S/. ${(results[index]['ganancias'] as num?)?.toStringAsFixed(2) ?? '0.00'}',
                  ],
                ),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellPadding: pw.EdgeInsets.all(5),
                cellStyle: const pw.TextStyle(fontSize: 10),
              ),
            ];
          },
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(
                'Página ${context.pageNumber} de ${context.pagesCount}',
                style: pw.TextStyle(fontSize: 10),
              ),
            );
          },
        ),
      );

      // Guardar y mostrar el PDF
      final path = await generarPDF(pdf, "reporte_productos_vendidos.pdf");
      debugPrint('PDF generado en: $path');

      if (context.mounted) {
        await mostrarPDF(context, path);
      }
    } catch (e, stackTrace) {
      debugPrint('Error al generar el reporte: $e');
      debugPrint('StackTrace: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar el reporte: $e')),
        );
      }
    }
  }

  // Añade este método para debug
  Future<void> verificarBaseDatos() async {
    try {
      final db = await DatabaseHelper.instance.database;

      // Verifica las tablas existentes
      final tables = await db
          .rawQuery("SELECT name FROM sqlite_master WHERE type='table';");
      debugPrint('Tablas en la base de datos: $tables');

      // Verifica la estructura y datos de cada tabla relevante
      debugPrint('\n=== Verificando estructura de tablas ===');

      // Verifica tabla Venta
      final ventasInfo = await db.rawQuery('PRAGMA table_info(Venta)');
      debugPrint('Estructura tabla Venta: $ventasInfo');
      final countVentas =
          await db.rawQuery('SELECT COUNT(*) as count FROM Venta');
      debugPrint(
          'Cantidad de registros en Venta: ${countVentas.first['count']}');

      // Verifica tabla DetalleVenta
      final detallesInfo = await db.rawQuery('PRAGMA table_info(DetalleVenta)');
      debugPrint('Estructura tabla DetalleVenta: $detallesInfo');
      final countDetalles =
          await db.rawQuery('SELECT COUNT(*) as count FROM DetalleVenta');
      debugPrint(
          'Cantidad de registros en DetalleVenta: ${countDetalles.first['count']}');

      // Verifica tabla Producto
      final productosInfo = await db.rawQuery('PRAGMA table_info(Producto)');
      debugPrint('Estructura tabla Producto: $productosInfo');
      final countProductos =
          await db.rawQuery('SELECT COUNT(*) as count FROM Producto');
      debugPrint(
          'Cantidad de registros en Producto: ${countProductos.first['count']}');

      // Verifica datos de ejemplo
      debugPrint('\n=== Verificando datos de ejemplo ===');

      // Muestra algunas ventas recientes si existen
      final ventasRecientes = await db.rawQuery('''
        SELECT v.idVenta, v.fecha, COUNT(dv.idDetalleVenta) as items
        FROM Venta v
        LEFT JOIN DetalleVenta dv ON v.idVenta = dv.idVenta
        GROUP BY v.idVenta
        ORDER BY v.fecha DESC
        LIMIT 5
      ''');
      debugPrint('Ventas recientes: $ventasRecientes');

      // Muestra algunos productos con ventas si existen
      final productosVendidos = await db.rawQuery('''
        SELECT p.codigo, p.nombre, SUM(dv.cantidad) as total_vendido
        FROM Producto p
        LEFT JOIN DetalleVenta dv ON p.idProducto = dv.idProducto
        GROUP BY p.idProducto
        HAVING total_vendido > 0
        LIMIT 5
      ''');
      debugPrint('Productos con ventas: $productosVendidos');
    } catch (e, stackTrace) {
      debugPrint('Error al verificar la base de datos: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }
}

// Modifica la clase _PDFViewerScreen
class _PDFViewerScreen extends StatelessWidget {
  final String pdfPath;
  const _PDFViewerScreen({Key? key, required this.pdfPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reporte de Productos Vendidos"),
      ),
      body: FutureBuilder<Uint8List>(
        future: File(pdfPath).readAsBytes(),
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
}
