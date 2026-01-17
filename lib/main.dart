import 'package:flutter/material.dart';
import 'screens/heart_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SmartHelp',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const HeartRateScreen(), 
    );
  }
}