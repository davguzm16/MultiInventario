import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/report_controller.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/venta.dart';
import 'package:multiinventario/models/cliente.dart';
import 'package:multiinventario/models/lote.dart';


class ReportDetailsPage extends StatefulWidget {
  const ReportDetailsPage({super.key});

  @override
  State<ReportDetailsPage> createState() => _ReportDetailsPageState();
}

class _ReportDetailsPageState extends State<ReportDetailsPage> {
    late TextEditingController fechaInicio;
    late TextEditingController fechaFinal;
    DateTime selectedFechaInicio = DateTime.now();
    DateTime selectedFechaFinal = DateTime.now();
    bool _isLoading = false;

    //pantalla de carga
    void _generateReport(DateTime selectedFechaInicio, DateTime selectedFechaFinal) async {
    setState(() {
      _isLoading = true;
    });
    await generarVentasContado(context, selectedFechaInicio, selectedFechaFinal);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fechaInicio = TextEditingController(
      text: DateTime.now().toIso8601String().split('T')[0],
    );
    fechaFinal = TextEditingController(
      text: DateTime.now().toIso8601String().split('T')[0], 
    );

    
  }

  @override
  void dispose() {
    fechaInicio.dispose();
    fechaFinal.dispose();
    super.dispose();
  }

  
  bool Selected = true;
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Reportes"),
      ),
      body: 
      
      Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
        children: [
          Text("Elegir tipo", style: TextStyle(color: Color(0xFF493D9E)),),
          _buildPagoButton("Reporte general detallado de ventas", Selected, context),
          _buildPagoButton("Reporte general detallado de ventas", Selected, context),
          _buildPagoButton("Reporte general detallado de ventas", Selected, context),
          _buildPagoButton("Reporte general detallado de ventas", Selected, context),
          SizedBox(height: 16,),
          Text("Elegir rango", style: TextStyle(color: Color(0xFF493D9E)),),
          SizedBox(height: 16,),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150,
                  height: 50,
                  child: TextField(
                    controller: fechaInicio,
                    decoration: InputDecoration(
                      labelText: 'Fecha Inicio',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                          color: Color(0xFF493D9e),
                        )
                      )
       
                    ),
                    readOnly: true,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedFechaInicio.isAfter(selectedFechaFinal) ? selectedFechaFinal : selectedFechaInicio, 
                        firstDate: DateTime(2000),
                        lastDate: selectedFechaFinal.isBefore(DateTime(2000)) ? DateTime(2000) : selectedFechaFinal,
                      );
                      if (picked != null) {
                        setState(() {
                          selectedFechaInicio = picked;
                          fechaInicio.text =
                              picked.toIso8601String().split('T')[0];
                        });
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 150,
                  height: 50,
                  child: TextField(
                    controller: fechaFinal,
                    decoration: InputDecoration(
                      labelText: 'Fecha Final',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                          color: Color(0xFF493D9e),
                        )
                      )
       
                    ),
                    readOnly: true,
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedFechaFinal.isBefore(selectedFechaInicio) ? selectedFechaInicio : selectedFechaFinal,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedFechaFinal = picked;
                          fechaFinal.text =
                              picked.toIso8601String().split('T')[0];
                        if(selectedFechaInicio!.isAfter(selectedFechaFinal)){
                          selectedFechaInicio = selectedFechaFinal;
                          fechaInicio.text = selectedFechaFinal.toIso8601String().split('T')[0];
                        }
                        
                        });
                      }
                    },
                  ),
                ),
                
              ],
            ),
            SizedBox(height: 10),

            SizedBox(
              width: 150,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF493D9e),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed:(){_generateReport(selectedFechaInicio, selectedFechaFinal);}, 
                child: const Text("Generar", style: TextStyle(fontSize: 18, color: Colors.white,)),
            )
            )
          
        ],
        )
      )
    );
  }
}







Widget _buildPagoButton(String text, bool isSelected, BuildContext context) {
  return OutlinedButton(
    style: OutlinedButton.styleFrom(
      backgroundColor: isSelected ? Color(0xFF493D9E) : Colors.white,
      foregroundColor: isSelected ? Colors.white : Color(0xFF493D9E),
      side: const BorderSide(color: Color(0xFF493D9E)),
    ),
    onPressed: () async {},
    child: Text(text),
  );
}

//Widget _






  
  Future<void> generarVentasContado(BuildContext context, DateTime selectedFechaInicio, DateTime selectedFechaFinal) async {
    List<DetalleVenta> detalles = [];
    List<Producto> productos = [];
    List<Venta> ventas = [];
    final ReportController report  = ReportController(); 
    final pdf = pw.Document();
    final datosTabla = await obtenerDatosTabla(selectedFechaInicio, selectedFechaFinal);
    String nombreCliente = "";
    try{
      detalles = await DetalleVenta.obtenerDetallesPorFechas(selectedFechaInicio, selectedFechaFinal);
      productos = await Producto.obtenerProductosPorFechas(selectedFechaInicio, selectedFechaFinal);
      ventas = await Venta.obtenerVentasporFecha(selectedFechaInicio, selectedFechaFinal);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape, 
          
          margin: pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              pw.Text("Reporte general detallado de ventas",
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Fecha: 01/01/2025 - 31/01/2025"),
              pw.Text("Total: S/ 1000.00"),
              pw.Text("Ganancias estimadas: S/ 300.00"),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: [
                  "#", "Fecha y hora", "Codigo de venta", "Tipo", "Cliente","Codigo del producto", "Descripcion del producto", "Cantidad", "Precio de compra por unidad (S/)","Precio de ventar por unidad (S/)" ,"Descuento (S/)", "Subtotal (S/)", "Ganancia estimada (S/)", "Estado"
                ],
                //generar filas
                data: datosTabla,
                
                border: pw.TableBorder.all(),
                cellStyle: pw.TextStyle(fontSize: 10),
                headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: PdfColors.black, borderRadius: pw.BorderRadius.circular(2)),
                headerAlignments: {0: pw.Alignment.center, 1: pw.Alignment.center, 2: pw.Alignment.centerLeft, 3: pw.Alignment.center, 4: pw.Alignment.center, 5: pw.Alignment.center, 6: pw.Alignment.center, 7: pw.Alignment.center, 8: pw.Alignment.center, 9: pw.Alignment.center, 10: pw.Alignment.center, 11: pw.Alignment.center, 12: pw.Alignment.center, 13: pw.Alignment.center},
                //Ajustar tamaño
                columnWidths: {
                  0: pw.FixedColumnWidth(35),  // Índice
                  1: pw.FixedColumnWidth(60),  // Fecha y hora
                  2: pw.FixedColumnWidth(50),  // Código de venta
                  3: pw.FixedColumnWidth(50),  // Tipos
                  4: pw.FixedColumnWidth(80),  // Cliente
                  5: pw.FixedColumnWidth(60), // Codigo del producto
                  6: pw.FixedColumnWidth(80),  // Descripcion
                  7: pw.FixedColumnWidth(35),  // Cantidad
                  8: pw.FixedColumnWidth(55),  // Precio de compra
                  9: pw.FixedColumnWidth(55),  // Precio de venta
                  10: pw.FixedColumnWidth(60), // Descuento
                  11: pw.FixedColumnWidth(60), // Subtotal 
                  12: pw.FixedColumnWidth(60), // ganancia
                  13: pw.FixedColumnWidth(60) //estado
                },
              ),
            ];
          },
        ),
      );
    }catch(e){
      debugPrint("Error ${e}");
    };
    //metodos de report_controller.dart
    
    //generar pdf
    final path = await report.generarPDF(pdf, "ventas_contado.pdf");
    //mostrar pdf
    report.mostrarPDF(context, path);
  }

Future<List<List<String>>> obtenerDatosTabla(DateTime selectedFechaInicio, selectedFechaFinal) async {
  List<DetalleVenta> detalles = [];
  List<Venta> ventas = [];
  List<List<String>> data = [];


  detalles = await DetalleVenta.obtenerDetallesPorFechas(selectedFechaInicio, selectedFechaFinal);
  ventas = await Venta.obtenerVentasporFecha(selectedFechaInicio, selectedFechaFinal);
      
  
  for (int i = 0; i < detalles.length; i++) {
    Cliente? cliente = await Cliente.obtenerClientePorId(ventas[i].idCliente);
    Lote? lote = await Lote.obtenerLotePorId(detalles[i].idLote);
    Producto? producto = await Producto.obtenerProductoPorID(detalles[i].idProducto);
    String nombreCliente = cliente != null ? cliente.nombreCliente : "Desconocido";
    String nombreProducto = producto != null? producto.nombreProducto : "Desconocido";
    double precioCompraUnidad = lote != null ? lote.precioCompra : 0;
    double precioVenta = producto != null ? producto.precioProducto : 0;
    String estado = (ventas[i].montoCancelado == ventas[i].montoTotal) ? "Cancelado" : "No cancelado";

    data.add([
      "${i + 1}",  //indice
      "${ventas[i].fechaVenta}",       //fecha y hora
      "${ventas[i].idVenta}", //Codigo de venta
      "${(ventas[i].esAlContado == true) ? "Contado" : "Crédito"}" , //Tipos
      nombreCliente, //Cliente
      "${detalles[i].idProducto}", 
      nombreProducto, 
      "${detalles[i].cantidadProducto}",
      "${detalles[i].precioUnidadProducto}",
      "${precioCompraUnidad}",
      "${precioVenta}",
      "${detalles[i].descuentoProducto}",
      "${detalles[i].subtotalProducto}",
      "${detalles[i].gananciaProducto}",
      estado
    ]);
  
}
return data;
}