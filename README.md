# SmartHelp — Ambient Assisted Living

Aplikacja Flutter wspierająca samodzielne mieszkanie osób starszych i z niepełnosprawnościami.
Opiekun lub sam użytkownik widzi w jednym miejscu parametry życiowe z czujników (tętno, saturacja),
lokalizację GPS, alarmy o upadkach, temperaturę w mieszkaniu i kalendarz z przypomnieniami.
Dane pobierane są z serwera projektu przez sieć Tor (ukryta usługa `.onion`), więc nie wymagają
publicznego adresu IP po stronie urządzeń pomiarowych.

<p>
<img width="49%" alt="Zrzut ekranu aplikacji SmartHelp" src="https://github.com/user-attachments/assets/378f56ae-f7fc-43ad-94bb-ccbc846435c1" />
<img width="49%" alt="Zrzut ekranu aplikacji SmartHelp" src="https://github.com/user-attachments/assets/7aa42724-8c55-4940-b29b-a97a5b2e5a3a" />
<img width="49%" alt="Zrzut ekranu aplikacji SmartHelp" src="https://github.com/user-attachments/assets/ad09130a-fa69-4480-a106-30381e236d8c" />
<img width="49%" alt="Zrzut ekranu aplikacji SmartHelp" src="https://github.com/user-attachments/assets/49962f6a-5c89-4af3-b161-a42c7707f302" />
<img width="49%" alt="Zrzut ekranu aplikacji SmartHelp" src="https://github.com/user-attachments/assets/a329d3a3-9309-4251-a7ad-16f8836ae81e" />
<img width="49%" alt="Zrzut ekranu aplikacji SmartHelp" src="https://github.com/user-attachments/assets/925c36b3-fb6c-4bb5-9696-b7028ae67e90" />
</p>

![Flutter](https://img.shields.io/badge/Flutter-Dart%203-02569B?logo=flutter)
![Tor](https://img.shields.io/badge/transport-Tor%20SOCKS5-7D4698?logo=torproject&logoColor=white)
![Platforms](https://img.shields.io/badge/platforms-Windows%20%7C%20Android-informational)

## Funkcje

- **Tętno i saturacja** — bieżący odczyt odświeżany co kilka sekund, kolorowa ocena wartości
  (np. tętno < 60 lub > 100 bpm, SpO₂ < 95% / < 90%) oraz wykresy historii (fl_chart).
- **Lokalizacja** — mapa (flutter_map, kafelki CARTO; ciemne w trybie wysokiego kontrastu) z ostatnią pozycją GPS, aktualizowana co 10 s.
- **Alarmy** — zdarzenia z serwera (np. upadek, stan krytyczny) wywołują natychmiastowe
  powiadomienie systemowe; ikona dzwonka pokazuje listę ostatnich zdarzeń.
- **Kalendarz** — wydarzenia i przypomnienia (również cykliczne) zapisywane lokalnie,
  z lokalnymi powiadomieniami.
- **Temperatura** — ustawianie docelowej temperatury w mieszkaniu (16–28 °C) z kolorowym wskaźnikiem.
- **Dostępność** — tryb wysokiego kontrastu, polska lokalizacja dat.

## Architektura

```
czujniki / opaska ──► serwer (ukryta usługa Tor .onion) ──► SOCKS5 127.0.0.1:9050 ──► aplikacja SmartHelp
                       /pomiary/ostatni                    (tor.exe uruchamiany
                       /pomiary/historia                    przez aplikację)
                       /lokalizacja/ostatnia
                       /zdarzenia
```

Na Windowsie aplikacja przy starcie wypakowuje `tor.exe` z zasobów, uruchamia go na porcie 9050
i kieruje przez niego wszystkie zapytania HTTP (Dio + `socks5_proxy`).

## Uruchomienie

Wymagany [Flutter SDK](https://docs.flutter.dev/get-started/install) z Dart 3.10+.

```bash
flutter pub get
flutter run -d windows
```

**Tor:** plik `assets/bin/tor.exe` nie jest w repozytorium. Pobierz Tor Expert Bundle
z [torproject.org](https://www.torproject.org/download/tor/) i umieść `tor.exe` w `assets/bin/`
przed buildem. Na innych platformach uruchom Tora samodzielnie (SOCKS na `127.0.0.1:9050`).
Adres serwera ustawia się w `lib/connection/api_service.dart` (`baseUrl`).

## Struktura

```
lib/
  main.dart                    start Tora, inicjalizacja powiadomień, motyw, nawigacja
  connection/
    api_service.dart           klient HTTP przez Tor (Dio + SOCKS5)
    pomiar_model.dart          modele: Pomiar, Lokalizacja, Zdarzenie
  screens/
    heart_screen.dart                   tętno
    blood_saturation_screen.dart        saturacja
    *_history_screen.dart, history_screen.dart   historia pomiarów i zdarzeń
    map_screen.dart                     lokalizacja na mapie
    calendar_screen.dart                kalendarz i przypomnienia
    temp_screen.dart                    temperatura w mieszkaniu
  services/                    powiadomienia lokalne, motyw, serwis pomiarów
  widgets/                     wspólne komponenty, dzwonek powiadomień
assets/                        ikony SVG (serce, saturacja)
```

## Technologie

Flutter · Dart · Dio · socks5_proxy · Tor · flutter_map · latlong2 · fl_chart · table_calendar ·
flutter_local_notifications · shared_preferences · intl

## Zespół

Projekt grupowy realizowany na studiach.
