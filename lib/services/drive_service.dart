import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';

class DriveService {
  final String idCarpetaBackup = "1pliOy57wy3QpKdmwZNCueKvBRBtjlOcx";

  Future<drive.DriveApi> conectar() async {
    try {
      // Cargar credenciales del archivo .env
      String jsonCredenciales = dotenv.env['SERVICE_ACCOUNT_JSON'] ?? '';

      if (jsonCredenciales.isEmpty) {
        throw Exception("No se encontraron credenciales en .env");
      }

      // Convertir de String a JSON
      final Map<String, dynamic> credencialesMap = jsonDecode(jsonCredenciales);

      // Crear objeto de credenciales
      final ServiceAccountCredentials credenciales =
          ServiceAccountCredentials.fromJson(credencialesMap);

      // Crear autenticación con Google Drive
      final AuthClient clienteAutenticado = await clientViaServiceAccount(
          credenciales, [drive.DriveApi.driveScope]);

      debugPrint("Credenciales leidas correctamente!");

      return drive.DriveApi(clienteAutenticado);
    } catch (e) {
      debugPrint("Error al conectar con la API de Drive: $e");
      rethrow;
    }
  }

  Future<drive.File?> crearCarpetaSiNoExiste(String nombreCarpeta) async {
    final driveApi = await conectar();

    // Validar si el nombre de la carpeta es válido
    if (nombreCarpeta.isEmpty) {
      throw Exception("El nombre de la carpeta no puede estar vacío.");
    }

    debugPrint("Nombre carpeta: $nombreCarpeta");

    final consulta =
        "'$idCarpetaBackup' in parents and name = '$nombreCarpeta' and mimeType = 'application/vnd.google-apps.folder' and trashed = false";

    final carpetasExistentes = await driveApi.files.list(
      q: consulta,
      spaces: 'drive',
    );

    if (carpetasExistentes.files!.isNotEmpty) {
      return carpetasExistentes.files!.first;
    }

    final metadatosCarpeta = drive.File()
      ..name = nombreCarpeta
      ..mimeType = 'application/vnd.google-apps.folder'
      ..parents = [idCarpetaBackup];

    return await driveApi.files.create(metadatosCarpeta);
  }

  Future<drive.File?> subirArchivo(
    String rutaArchivo,
    String nombreArchivo,
    String idCarpeta,
  ) async {
    final driveApi = await conectar();
    final bytesArchivo = await File(rutaArchivo).readAsBytes();
    final media = drive.Media(
      Stream.fromIterable([bytesArchivo]),
      bytesArchivo.length,
    );

    final metadatosArchivo = drive.File()
      ..name = nombreArchivo
      ..parents = [idCarpeta];

    return await driveApi.files.create(metadatosArchivo, uploadMedia: media);
  }

  Future<drive.File?> actualizarArchivo(
    String rutaArchivo,
    String idArchivo,
  ) async {
    final driveApi = await conectar();
    final bytesArchivo = await File(rutaArchivo).readAsBytes();
    final media = drive.Media(
      Stream.fromIterable([bytesArchivo]),
      bytesArchivo.length,
    );

    return await driveApi.files.update(
      drive.File(),
      idArchivo,
      uploadMedia: media,
    );
  }

  Future<bool> descargarArchivo(String idArchivo, String rutaDestino) async {
    try {
      final driveApi = await conectar();
      final archivo = await driveApi.files
          .get(idArchivo, downloadOptions: drive.DownloadOptions.fullMedia);

      if (archivo is drive.Media) {
        final fileStream = File(rutaDestino).openWrite();
        await archivo.stream.pipe(fileStream);
        await fileStream.flush();
        await fileStream.close();
        debugPrint("Archivo descargado correctamente en $rutaDestino");
        return true;
      }

      debugPrint("No se pudo descargar el archivo.");
      return false;
    } catch (e) {
      debugPrint("Error al descargar el archivo: $e");
      return false;
    }
  }

  static Future<bool> exportarBD(String correoUsuario, String rutaBD) async {
    try {
      final driveService = DriveService();
      final driveApi = await driveService.conectar();

      // Usar el correo como nombre de carpeta y evitar interpretarlo como ruta
      final carpeta = await driveService.crearCarpetaSiNoExiste(correoUsuario);

      if (carpeta == null) {
        return false;
      }

      final consultaArchivo =
          "'${carpeta.id}' in parents and name = 'backup.sqlite' and trashed = false";
      final archivosExistentes = await driveApi.files.list(
        q: consultaArchivo,
        spaces: 'drive',
      );

      if (archivosExistentes.files!.isNotEmpty) {
        final resultado = await driveService.actualizarArchivo(
          rutaBD,
          archivosExistentes.files!.first.id!,
        );

        if (resultado != null) {
          debugPrint("Exportación realizada correctamente!");
          return true;
        }
      } else {
        final resultado = await driveService.subirArchivo(
          rutaBD,
          "backup.sqlite",
          carpeta.id!,
        );

        if (resultado != null) {
          debugPrint("Exportación realizada correctamente!");
          return true;
        }
      }
    } catch (e) {
      debugPrint("Error en sincronización: $e");
    }

    return false;
  }

  static Future<bool> importarBD(
      String correoUsuario, String rutaDestino) async {
    try {
      final driveService = DriveService();
      final driveApi = await driveService.conectar();
      final carpeta = await driveService.crearCarpetaSiNoExiste(correoUsuario);

      if (carpeta == null) {
        return false;
      }

      // Buscar el archivo de backup en la carpeta del usuario
      final consultaArchivo =
          "'${carpeta.id}' in parents and name = 'backup.sqlite' and trashed = false";
      final archivosExistentes = await driveApi.files.list(
        q: consultaArchivo,
        spaces: 'drive',
      );

      if (archivosExistentes.files!.isEmpty) {
        debugPrint("No se encontró un backup en Google Drive.");
        return false;
      }

      final idArchivo = archivosExistentes.files!.first.id!;
      final archivoDescargado =
          await driveService.descargarArchivo(idArchivo, rutaDestino);

      if (archivoDescargado) {
        debugPrint("Exportación realizada correctamente!");
        return true;
      }
    } catch (e) {
      debugPrint("Error al importar la base de datos: $e");
    }

    return false;
  }
}
