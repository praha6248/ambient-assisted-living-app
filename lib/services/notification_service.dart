import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Model pojedynczego powiadomienia
class AppNotification {
  final String title;
  final String time;
  final bool isRead;

  AppNotification({required this.title, required this.time, this.isRead = false});

  // Zamiana na tekst (do zapisu)
  Map<String, dynamic> toJson() => {
    'title': title,
    'time': time,
    'isRead': isRead,
  };

  // Odtworzenie z tekstu (odczyt)
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      title: json['title'],
      time: json['time'],
      isRead: json['isRead'] ?? false,
    );
  }
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    _loadNotifications(); // Startujemy odczyt przy uruchomieniu
  }

  final List<AppNotification> _notifications = [];
  final ValueNotifier<int> unreadCount = ValueNotifier(0);

  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  // --- DODAWANIE POWIADOMIENIA ---
  Future<void> addNotification(String title, String time) async {
    // Dodajemy na początek listy
    _notifications.insert(0, AppNotification(title: title, time: time));
    _updateUnreadCount();
    await _saveNotifications(); // Zapisujemy zmiany
  }

  // --- OZNACZANIE JAKO PRZECZYTANE ---
  Future<void> markAllAsRead() async {
    unreadCount.value = 0;
    // (Opcjonalnie: można tu zmieniać flagę isRead w obiektach, 
    // ale na razie wystarczy wyzerowanie licznika dla dzwonka)
  }

  void _updateUnreadCount() {
    // Prosta logika: każde dodanie zwiększa licznik
    // (W pełnej wersji liczylibyśmy elementy z isRead == false)
    unreadCount.value++;
  }

  // --- ZAPIS DO PAMIĘCI TELEFONU ---
  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    // Zamieniamy listę obiektów na listę tekstów JSON
    final String encodedData = jsonEncode(
      _notifications.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('saved_notifications', encodedData);
    await prefs.setInt('saved_unread_count', unreadCount.value);
  }

  // --- ODCZYT Z PAMIĘCI TELEFONU ---
  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Wczytaj licznik
    unreadCount.value = prefs.getInt('saved_unread_count') ?? 0;

    // 2. Wczytaj listę
    final String? savedString = prefs.getString('saved_notifications');
    if (savedString != null) {
      final List<dynamic> decodedList = jsonDecode(savedString);
      _notifications.clear();
      _notifications.addAll(
        decodedList.map((e) => AppNotification.fromJson(e)).toList(),
      );
    }
  }
}