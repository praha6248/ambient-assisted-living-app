import 'package:flutter/material.dart';

class ThemeService {
  // Singleton - jedna instancja na całą aplikację
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  // Zmienna, której słuchamy: false = normalny, true = wysoki kontrast
  final ValueNotifier<bool> isHighContrast = ValueNotifier(false);

  void toggle() {
    isHighContrast.value = !isHighContrast.value;
  }
}