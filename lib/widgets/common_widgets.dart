import 'package:flutter/material.dart';
import '../screens/heart_screen.dart';
import '../screens/temp_screen.dart';
import '../screens/map_screen.dart';
import '../screens/history_screen.dart';
import '../screens/calendar_screen.dart'; 

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'SmartHelp',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Row(
            children: [
              _textButton('A'),
              const SizedBox(width: 8),
              _textButton('A+'),
              const SizedBox(width: 8),
              _textButton('A++'),
              const SizedBox(width: 12),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                child: const Text('A', style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _textButton(String text) => Text(text, style: const TextStyle(color: Colors.grey, fontSize: 16));
}

class CustomBottomNavBar extends StatelessWidget {
  final int activeIndex; 
  const CustomBottomNavBar({super.key, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navItem(context, Icons.device_thermostat, isActive: activeIndex == 0, targetPage: const TemperatureScreen()),
          _navItem(context, Icons.favorite_border, isActive: activeIndex == 1, targetPage: const HeartRateScreen()),
          _navItem(context, Icons.location_on_outlined, isActive: activeIndex == 2, targetPage: const MapScreen()),
          _navItem(context, Icons.calendar_today_outlined, isActive: activeIndex == 3, targetPage: const CalendarScreen()),
          _navItem(context, Icons.history, isActive: activeIndex == 4, targetPage: const HistoryScreen()),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, {required bool isActive, Widget? targetPage}) {
    return GestureDetector(
      onTap: () {
        if (targetPage != null && !isActive) {
          Navigator.pushReplacement(context, PageRouteBuilder(
            pageBuilder: (context, anim1, anim2) => targetPage,
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: isActive ? const BoxDecoration(color: Color(0xFF333333), shape: BoxShape.circle) : null,
        child: Icon(icon, size: 26, color: isActive ? Colors.white : Colors.black54),
      ),
    );
  }
}