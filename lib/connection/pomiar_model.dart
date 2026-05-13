/*
Transport modelu danych dla pomiarów tętna i saturacji krwi.
Czyli tłumaczenie danych z formatu JSON otrzymanego z serwera na obiekt Dart, który można łatwo używać w aplikacji Flutter.
*/
class Pomiar {
  final String data;
  final int tetno;
  final double saturacja;

  Pomiar({required this.data, required this.tetno, required this.saturacja});

  factory Pomiar.fromJson(Map<String, dynamic> json) {
    return Pomiar(
      data: json['data'],
      tetno: json['tetno'],
      saturacja: json['saturacja'].toDouble(),
    );
  }
}

class Lokalizacja {
  final String data;
  final double lat;
  final double lon;

  Lokalizacja({required this.data, required this.lat, required this.lon});

  factory Lokalizacja.fromJson(Map<String, dynamic> json) {
    return Lokalizacja(
      data: json['data'],
      lat: json['lat'].toDouble(),
      lon: json['lon'].toDouble(),
    );
  }
}

class Zdarzenie {
  final String data;
  final String typ_zdarzenia;

  Zdarzenie({required this.data, required this.typ_zdarzenia});

  factory Zdarzenie.fromJson(Map<String, dynamic> json) {
    return Zdarzenie(data: json['data'], typ_zdarzenia: json['typ_zdarzenia']);
  }
}
