// features/controller/data/esp32_repository.dart
import 'package:http/http.dart' as http;

class ESP32Repository {
  static const String baseUrl = "http://192.168.4.1";

  Future<void> enviarComando(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
      if (response.statusCode == 200) {
        print("Comando $endpoint enviado con éxito");
      }
    } catch (e) {
      print("Error de red: $e");
    }
  }
}