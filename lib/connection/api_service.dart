import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'pomiar_model.dart';

class ApiService {
  late Dio _dio;
  final String baseUrl =
      "http://eyfqp7vhlaxmo7adqdwz53golzfylabwzg6xoxqfpdve5g6xv6yvoyyd.onion";

  ApiService() {
    _dio = Dio();

    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        // Łączymy się z lokalnym portem, który otworzył tor_rest
        client.findProxy = (uri) => "SOCKS5 127.0.0.1:9050";
        return client;
      },
    );

    _dio.options.connectTimeout = const Duration(seconds: 30);
  }

  Future<Pomiar> getOstatniPomiar() async {
    try {
      final response = await _dio.get('$baseUrl/pomiary/ostatni');
      return Pomiar.fromJson(response.data);
    } catch (e) {
      throw Exception('Aplikacja nie mogła pobrać danych przez Tor: $e');
    }
  }
}
