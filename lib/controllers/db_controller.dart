import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseController {
  static final DatabaseController _instance = DatabaseController._internal();
  static Database? _database;

  factory DatabaseController() {
    return _instance;
  }

  DatabaseController._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'inventario_ventas.db');
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
            estaDisponible BOOLEAN NOT NULL DEFAULT 1,
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
            nombreCliente TEXT NOT NULL,
            dniCliente TEXT UNIQUE
          )
        ''');

        await db.execute('''
          CREATE TABLE Ventas (
            idVenta INTEGER PRIMARY KEY,
            idCliente INTEGER,
            codigoVenta TEXT NOT NULL UNIQUE,
            totalVenta REAL NOT NULL,
            fechaVenta DATETIME DEFAULT CURRENT_TIMESTAMP,
            estaCancelado BOOLEAN NOT NULL DEFAULT 1,
            FOREIGN KEY (idCliente) REFERENCES Clientes(idCliente)
          )
        ''');

        await db.execute('''
          CREATE TABLE DetallesVentas (
            idProducto INTEGER,
            idVenta INTEGER,
            cantidadProducto INTEGER NOT NULL,
            subtotalProducto REAL NOT NULL,
            descuentoProducto REAL,
            FOREIGN KEY (idProducto) REFERENCES Productos(idProducto),
            FOREIGN KEY (idVenta) REFERENCES Ventas(idVenta)
          )
        ''');

        await db.execute('''
          CREATE TABLE Lotes (
            idLote INTEGER PRIMARY KEY,
            idProducto INTEGER,
            cantidadAsignada INTEGER NOT NULL,
            cantidadPerdida INTEGER,
            precioCompra REAL NOT NULL,
            fechaCaducidad DATETIME,
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
}
