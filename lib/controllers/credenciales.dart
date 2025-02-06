import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:multiinventario/controllers/db_controller.dart';

class Credenciales {
  static final key = encrypt.Key.fromUtf8('16byteslongkey!!');
  static final iv = encrypt.IV.fromUtf8('16byteslongiv!!!');

  static String encryptPassword(String password) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64;
  }

  static String decryptPassword(String encryptedPassword) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt64(encryptedPassword, iv: iv);
    return decrypted;
  }

  static Future<String> obtenerCredencial(String tipoCredencial) async {
    try {
      final db = await DatabaseController().database;
      final List<Map<String, dynamic>> result = await db.rawQuery(
        'SELECT valorCredencial FROM Credenciales WHERE tipoCredencial = ?',
        [tipoCredencial],
      );

      if (result.isNotEmpty) {
        return decryptPassword(result.first['valorCredencial']);
      } else {
        return ''; // Retorna una cadena vacía si no hay resultados
      }
    } catch (e) {
      debugPrint("Error al obtener la credencial: $e");
      return ''; // Retorna una cadena vacía si ocurre un error
    }
  }

  static Future<bool> crearCredencial(
      String tipoCredencial, String valorCredencial) async {
    try {
      final db = await DatabaseController().database;
      final result = await db.rawInsert(
        'INSERT INTO Credenciales (tipoCredencial, valorCredencial) VALUES (?, ?)',
        [tipoCredencial, encryptPassword(valorCredencial)],
      );

      return result > 0;
    } catch (e) {
      debugPrint(e.toString());
    }

    return false;
  }

  static Future<void> crearCredencialesPorDefecto() async {
    if (await DatabaseController.tableHasData("Credenciales")) return;

    await dotenv.load(fileName: "lib/.env");

    String? addressSendEmail = dotenv.env['ADDRESS_SEND_EMAIL'];
    String? passwordSendEmail = dotenv.env['PASSWORD_SEND_EMAIL'];

    if (addressSendEmail!.isNotEmpty && passwordSendEmail!.isNotEmpty) {
      await crearCredencial('ADDRESS_SEND_EMAIL', addressSendEmail);
      await crearCredencial('PASSWORD_SEND_EMAIL', passwordSendEmail);
    }
  }
}
