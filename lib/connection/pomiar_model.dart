/*
Transport modelu danych dla pomiarów tętna i saturacji krwi.
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
      // Zabezpieczenie, gdyby serwer wysłał int zamiast double
      saturacja: json['saturacja'].toDouble(),
    );
  }
}
