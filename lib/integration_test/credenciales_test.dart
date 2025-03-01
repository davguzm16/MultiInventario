// seguiridad_test/credenciales_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:multiinventario/controllers/credenciales.dart';



void main() {
  test('Encriptación y desencriptación de contraseñas', () {
    final plainPassword = 'miSecretaContraseña';
    final encrypted = Credenciales.encryptPassword(plainPassword);
    // Verifica que la contraseña encriptada no sea igual al texto plano
    expect(encrypted, isNot(equals(plainPassword)));

    final decrypted = Credenciales.decryptPassword(encrypted);
    // Verifica que la desencriptación recupere el valor original
    expect(decrypted, equals(plainPassword));
  });
}
