import '../connection/pomiar_model.dart'; // Upewnij się, że ścieżka jest poprawna

class PomiarService {
  // Symulujemy pobranie danych z serwera (np. ostatnich 7 dni)
  static List<Pomiar> getPomiary() {
    return [
      Pomiar(data: '2023-10-18', tetno: 72, saturacja: 98.0),
      Pomiar(data: '2023-10-19', tetno: 75, saturacja: 97.0),
      Pomiar(data: '2023-10-20', tetno: 80, saturacja: 96.0),
      Pomiar(data: '2023-10-21', tetno: 78, saturacja: 98.0),
      Pomiar(data: '2023-10-22', tetno: 74, saturacja: 99.0),
      Pomiar(data: '2023-10-23', tetno: 82, saturacja: 95.0),
      Pomiar(data: '2023-10-24', tetno: 79, saturacja: 98.0),
    ];
  }

  // Pobieranie tylko najnowszego pomiaru na ekrany główne
  static Pomiar getOstatniPomiar() {
    return getPomiary().last;
  }
}
