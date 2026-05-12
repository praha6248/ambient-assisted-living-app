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
