import 'package:flutter/foundation.dart';
import 'package:multiinventario/controllers/credenciales.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/models/producto.dart';
import 'package:multiinventario/models/unidad.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

class DatabaseController {
  static final DatabaseController _instance = DatabaseController._internal();
  Database? _database;

  factory DatabaseController() => _instance;

  DatabaseController._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path;

    if (kIsWeb) {
      // Web
      databaseFactory = databaseFactoryFfiWeb;
      path = 'multiinventario_web.db';
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      // Windows y Linux
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      final documentsDirectory = await getApplicationDocumentsDirectory();
      path = join(documentsDirectory.path, 'multiinventario.db');
    } else {
      // iOS, Android, macOS
      path = join(await getDatabasesPath(), 'multiinventario.db');
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Categorias (
            idCategoria INTEGER PRIMARY KEY,
            nombreCategoria TEXT UNIQUE
          )
        ''');

        await db.execute('''
          CREATE TABLE Productos (
            idProducto INTEGER PRIMARY KEY,
            idUnidad INTEGER,
            codigoProducto TEXT UNIQUE,
            nombreProducto TEXT NOT NULL UNIQUE,
            precioProducto REAL NOT NULL,
            stockActual REAL NOT NULL,
            stockMinimo REAL,
            stockMaximo REAL,
            estaDisponible BOOLEAN DEFAULT 1,
            rutaImagen TEXT,
            fechaCreacion DATETIME DEFAULT CURRENT_TIMESTAMP,
            fechaModificacion DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (idUnidad) REFERENCES Unidades(idUnidad)
          )
        ''');

        await db.execute('''
          CREATE TABLE ProductosCategorias (
            idCategoria INTEGER,
            idProducto INTEGER,
            FOREIGN KEY (idCategoria) REFERENCES Categorias(idCategoria),
            FOREIGN KEY (idProducto) REFERENCES Productos(idProducto)
          )
        ''');

        await db.execute('''
          CREATE TABLE Unidades (
            idUnidad INTEGER PRIMARY KEY,
            tipoUnidad TEXT NOT NULL UNIQUE
          )
        ''');

        await db.execute('''
          CREATE TABLE Clientes (
            idCliente INTEGER PRIMARY KEY,
            nombreCliente TEXT,
            dniCliente TEXT,
            correoCliente TEXT,
            esDeudor BOOLEAN DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE Ventas (
            idVenta INTEGER PRIMARY KEY,
            idCliente INTEGER,
            codigoVenta TEXT NOT NULL UNIQUE,
            fechaVenta DATETIME DEFAULT CURRENT_TIMESTAMP,
            montoTotal REAL NOT NULL,
            montoCancelado REAL,
            esAlContado BOOLEAN DEFAULT 1,
            FOREIGN KEY (idCliente) REFERENCES Clientes(idCliente)
          )
        ''');

        await db.execute('''
          CREATE TABLE DetallesVentas (
            idProducto INTEGER,
            idLote INTEGER,
            idVenta INTEGER,
            cantidadProducto INTEGER NOT NULL,
            precioUnidadProducto REAL NOT NULL,
            subtotalProducto REAL NOT NULL,
            gananciaProducto REAL NOT NULL,
            descuentoProducto REAL,
            FOREIGN KEY (idProducto) REFERENCES Productos(idProducto),
            FOREIGN KEY (idLote) REFERENCES Lotes(idLote)
            FOREIGN KEY (idVenta) REFERENCES Ventas(idVenta)
          )
        ''');

        await db.execute('''
          CREATE TABLE Lotes (
            idLote INTEGER,
            idProducto INTEGER,
            cantidadActual INTEGER NOT NULL,
            cantidadComprada INTEGER NOT NULL,
            cantidadPerdida INTEGER,
            precioCompra REAL NOT NULL,
            precioCompraUnidad REAL NOT NULL,
            fechaCaducidad DATE,
            fechaCompra DATE,
            estaDisponible BOOLEAN DEFAULT 1,
            FOREIGN KEY (idProducto) REFERENCES Productos(idProducto)
          )
        ''');

        await db.execute('''
          CREATE TABLE Credenciales (
            idCredencial INTEGER PRIMARY KEY,
            tipoCredencial TEXT NOT NULL UNIQUE,
            valorCredencial TEXT NOT NULL UNIQUE
          )
        ''');
      },
    );
  }

  static Future<bool> tableHasData(String tableName) async {
    try {
      final db = await DatabaseController().database;
      final List<Map<String, Object?>> result = await db.rawQuery(
        "SELECT COUNT(*) FROM $tableName",
      );

      int count = Sqflite.firstIntValue(result) ?? 0;
      debugPrint("Número de registros en la tabla '$tableName': $count");

      return count > 0;
    } catch (e) {
      debugPrint("Error al consultar la tabla $tableName: $e");
      return false;
    }
  }

  static Future<void> insertDefaultData() async {
    Credenciales.crearCredencialesPorDefecto();
    Categoria.crearCategoriasPorDefecto();
    Unidad.crearUnidadesPorDefecto();
    Producto.insertarProductosPorDefecto();
  }
}
