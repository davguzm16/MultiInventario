import 'package:flutter/material.dart';
import 'package:multiinventario/controllers/report_controller.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:multiinventario/models/venta.dart';
import 'package:multiinventario/models/cliente.dart';


class ReportSalesPage extends StatefulWidget {
  const ReportSalesPage({super.key});

  @override
  State<ReportSalesPage> createState() => _ReportSalesPageState();
}

class _ReportSalesPageState extends State<ReportSalesPage> {
    late TextEditingController fechaInicio;
    late TextEditingController fechaFinal;
    DateTime selectedFechaInicio = DateTime.now();
    DateTime selectedFechaFinal = DateTime.now();
    String _selectedReport = "Reporte general de ventas"; 

    bool _isLoading = false;

    //pantalla de carga
void _generateReport(DateTime selectedFechaInicio, DateTime selectedFechaFinal) async {
  setState(() {
    _isLoading = true;
  });

  if (_selectedReport == "Reporte general de ventas") {
    await generarVentasGeneral(context, selectedFechaInicio, selectedFechaFinal);
  } else if(_selectedReport == "Reporte de ventas al contado"){
    await generarVentasTipo(context, selectedFechaInicio, selectedFechaFinal, true);
  } else if(_selectedReport == "Reporte de ventas al crédito"){
    await generarVentasTipo(context, selectedFechaInicio, selectedFechaFinal, false);
  }

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

          Padding(
            padding: EdgeInsets.only(left: 16), // Ajusta el espacio según necesites
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Reporte Ventas", 
                style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SizedBox(height: 8,),
         Padding(
            padding: EdgeInsets.only(left: 16), // Ajusta el espacio según necesites
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Elegir tipo", 
                style: TextStyle(color: Color(0xFF493D9E), fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          SizedBox(height: 16,),

          _buildButton("Reporte general de ventas", _selectedReport, context, (selected) {
            setState(() {
              _selectedReport = selected;
            });
          }),

          SizedBox(height: 16,),
          
          _buildButton("Reporte de ventas al contado", _selectedReport, context, (selected) {
            setState(() {
              _selectedReport = selected;
            });
          }),

          SizedBox(height: 16,),

          _buildButton("Reporte de ventas al crédito", _selectedReport, context, (selected) {
            setState(() {
              _selectedReport = selected;
            });
          }),

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
            SizedBox(height: 16),

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







Widget _buildButton(String text, String selectedReport, BuildContext context, Function(String) onSelect) {
  bool isSelected = text == selectedReport;

  return SizedBox(
    width: 250,
    height: 50,
    child: OutlinedButton(
    style: OutlinedButton.styleFrom(
      backgroundColor: isSelected ? Color(0xFF493D9E) : Colors.white,
      foregroundColor: isSelected ? Colors.white : Color(0xFF493D9E),
      side: const BorderSide(color: Color(0xFF493D9E)),
    ),
    onPressed: () {
      onSelect(text); 
    },
    child: Text(text),
  ),);
}









  
  Future<void> generarVentasGeneral(BuildContext context, DateTime selectedFechaInicio, DateTime selectedFechaFinal) async {

    final ReportController report  = ReportController(); 
    final pdf = pw.Document();
    final datosTablaGeneral = await obtenerDatosTablaGeneral(selectedFechaInicio, selectedFechaFinal);
    final datos = datosTablaGeneral["data"] as List<List<String>>;
    final gananciaTotal = datosTablaGeneral["totalGanancias"] as double;
    final ventasContado = datosTablaGeneral["ventasContado"] as int;
    final ventasCredito = datosTablaGeneral["ventasCredito"] as int;
    try{
      

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape, 
          
          margin: pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              pw.Text("Reporte general detallado de ventas",
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Fecha: ${selectedFechaInicio.toString().split(" ")[0]} - ${selectedFechaFinal.toString().split(" ")[0]}"),
              pw.Text("Total: S/ ${1}"),
              pw.Text("Ganancias estimadas: ${gananciaTotal}"),
              pw.Text("Ventas al contado: ${ventasContado}"),
              pw.Text("Ventas al crédito: ${ventasCredito}"),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: [
                  "#", "Fecha y hora", "Codigo de venta", "Tipo", "Cliente", "Subtotal (S/)","Descuento (S/)" ,"Monto total (S/)","Monto cancelado (S/)","Ganancia estimada (S/)", "Estado"
                ],
                //generar filas
                data: datos,
                
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
                  3: pw.FixedColumnWidth(50),  // Tipo
                  4: pw.FixedColumnWidth(80),  // Cliente
                  5: pw.FixedColumnWidth(60), // Subtotal
                  6: pw.FixedColumnWidth(80),  // Descuento
                  7: pw.FixedColumnWidth(35),  // Monto total
                  8: pw.FixedColumnWidth(55),  // Monto cancelado
                  9: pw.FixedColumnWidth(55),  // Ganacias estimadas
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

Future<Map<String, dynamic>> obtenerDatosTablaGeneral(DateTime selectedFechaInicio, selectedFechaFinal) async {
  List<Venta> ventas = [];
  List<List<String>> data = [];

  ventas = await Venta.obtenerVentasporFecha(selectedFechaInicio, selectedFechaFinal);
  double subtotal = 0;  
  double descuento = 0;
  double ganancia = 0;
  double totalGanancias = 0;
  int ventasContado = 0;
  int ventasCredito = 0;
  for (int i = 0; i < ventas.length; i++) {

    List<DetalleVenta> detalles = await DetalleVenta.obtenerDetallesPorVenta(ventas[i].idVenta!);
    Cliente? cliente = await Cliente.obtenerClientePorId(ventas[i].idCliente);
    String nombreCliente = cliente != null ? cliente.nombreCliente : "Desconocido";

    String estado = (ventas[i].montoCancelado == ventas[i].montoTotal) ? "Cancelado" : "No cancelado";
    
    //calculo de la suma de subtotales, descuentos y ganancias
    for(int j = 0; j<detalles.length; i++){


      subtotal = detalles[j].subtotalProducto+subtotal;
      if(detalles[j].descuentoProducto != null){
        descuento = detalles[j].descuentoProducto! + descuento;
      }
      ganancia = detalles[j].gananciaProducto + ganancia;
      
    }
    totalGanancias += ganancia;

    if(ventas[i].esAlContado == true){
      ventasContado++;
    } else{
      ventasCredito++;
    }


    data.add([
      "${i + 1}",  //indice
      "${ventas[i].fechaVenta}",       //fecha y hora
      "${ventas[i].idVenta}", //Codigo de venta
      "${(ventas[i].esAlContado == true) ? "Contado" : "Crédito"}" , //Tipos
      nombreCliente, //Cliente
      "${subtotal}",
      "${descuento}",
      "${ventas[i].montoTotal}",
      "${ventas[i].montoCancelado}",
      "${ganancia}",
      estado,
    ]);
  subtotal = 0;
  descuento = 0;
  ganancia = 0;
}
return {
  "data": data,
  "totalGanancias": totalGanancias,
  "ventasContado": ventasContado,
  "ventasCredito": ventasCredito,
  
  };
}


  Future<void> generarVentasTipo(BuildContext context, DateTime selectedFechaInicio, DateTime selectedFechaFinal, bool tipo) async {

    final ReportController report  = ReportController(); 
    final pdf = pw.Document();
    final datosTablaGeneral = await obtenerDatosTablaTipo(selectedFechaInicio, selectedFechaFinal, tipo);
    final datos = datosTablaGeneral['data'] as List<List<String>>;
    final ganancias = datosTablaGeneral['totalGanancias'] as double;
    final total = datosTablaGeneral['total'] as double;
    String tipoVenta = "";
    if(tipo == true){
      tipoVenta = "Reporte de ventas al contado";
    }else{
      tipoVenta = "Reporte de ventas al crédito";
    }
    try{
      

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape, 
          
          margin: pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              pw.Text(tipoVenta,
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text("Fecha: ${selectedFechaInicio.toString().split(" ")[0]} - ${selectedFechaFinal.toString().split(" ")[0]}"),
              pw.Text("Total: S/ ${total}"),
              pw.Text("Ganancias estimadas: S/ ${ganancias}"),
              pw.SizedBox(height: 10),
              pw.Table.fromTextArray(
                headers: [
                  "#", "Fecha y hora", "Codigo de venta", "Cliente", "Subtotal (S/)","Descuento (S/)" ,"Monto total (S/)","Ganancia estimada"
                ],
                //generar filas
                data: datos,
                
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
                  3: pw.FixedColumnWidth(50),  // Tipo
                  4: pw.FixedColumnWidth(80),  // Cliente
                  5: pw.FixedColumnWidth(60), // Subtotal
                  6: pw.FixedColumnWidth(80),  // Descuento
                  7: pw.FixedColumnWidth(35),  // Monto total
                  8: pw.FixedColumnWidth(55),  // Monto cancelado
                  9: pw.FixedColumnWidth(55),  // Ganacias estimadas
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

  Future<Map<String, dynamic>> obtenerDatosTablaTipo(DateTime selectedFechaInicio, selectedFechaFinal, bool tipo) async {
  List<Venta> ventas = [];
  List<List<String>> data = [];

  ventas = await Venta.obtenerVentasporFecha(selectedFechaInicio, selectedFechaFinal);
  double subtotal = 0;  
  double descuento = 0;
  double ganancia = 0;
  double totalGanancias = 0;
  double total = 0;
  for (int i = 0; i < ventas.length; i++) {
    if(ventas[i].esAlContado == tipo)
    {List<DetalleVenta> detalles = await DetalleVenta.obtenerDetallesPorVenta(ventas[i].idVenta!);
    Cliente? cliente = await Cliente.obtenerClientePorId(ventas[i].idCliente);
    String nombreCliente = cliente != null ? cliente.nombreCliente : "Desconocido";

    String estado = (ventas[i].montoCancelado == ventas[i].montoTotal) ? "Cancelado" : "No cancelado";
    
    //calculo de la suma de subtotales, descuentos y ganancias
    for(int j = 0; j<detalles.length; i++){
      
      subtotal = detalles[j].subtotalProducto+subtotal;
      if(detalles[j].descuentoProducto != null){
        descuento = detalles[j].descuentoProducto! + descuento;
      }
      ganancia = detalles[j].gananciaProducto + ganancia;
      
    }
    totalGanancias += ganancia;
    total = subtotal;
    

    data.add([
      "${i + 1}",  //indice
      "${ventas[i].fechaVenta}",       //fecha y hora
      "${ventas[i].idVenta}", //Codigo de venta
      nombreCliente, //Cliente
      "${subtotal}",
      "${descuento}",
      "${ventas[i].montoTotal}",
      "${ventas[i].montoCancelado}",
      "${ganancia}",
      estado,
    ]);
  subtotal = 0;
  descuento = 0;
  ganancia = 0;}
}
return {
  "data" : data,
  "totalGanancias": totalGanancias,
  "total": total, 

  };
}