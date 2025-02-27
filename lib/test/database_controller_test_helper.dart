// test/database_controller_test_helper.dart
import 'package:multiinventario/controllers/db_controller.dart';
import 'package:sqflite/sqflite.dart';

/// Inyecta la base de datos de test en el DatabaseController.
void setTestDatabase(Database? db) {
  DatabaseController.testDatabase = db;
}

/// Limpia la base de datos inyectada en el DatabaseController.
void clearTestDatabase() {
  DatabaseController.clearTestDatabase();
}
