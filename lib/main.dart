import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'services/local_notifications.dart'; 
import 'screens/temp_screen.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting('pl_PL', null);
  
  await LocalNotifications.init();

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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF669D)),
        fontFamily: 'Roboto', 
      ),
      home: const TemperatureScreen(), 
    );
  }
}