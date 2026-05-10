import 'dart:convert';
import 'package:http/http.dart' as http;
import 'pomiar_model.dart';

class ApiService {
  // ZMIEŃ TO NA IP TWOJEGO RASPBERRY (sprawdziłeś je w przeglądarce)
  final String baseUrl = "http://192.168.1.XX:8000";

  Future<Pomiar> pobierzOstatni() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/pomiary/ostatni'));

      if (response.statusCode == 200) {
        // Jeśli serwer odpowiedział OK (200), odkoduj JSON
        return Pomiar.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Błąd serwera: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Nie udało się połączyć z serwerem: $e');
    }
  }
}
