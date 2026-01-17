import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';

class TemperatureScreen extends StatefulWidget {
  const TemperatureScreen({super.key});

  @override
  State<TemperatureScreen> createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  double _currentTemp = 22.0;
  final double _minTemp = 16.0;
  final double _maxTemp = 28.0;

  void _increaseTemp() {
    setState(() {
      if (_currentTemp < _maxTemp) {
        _currentTemp += 1.0;
      }
    });
  }

  void _decreaseTemp() {
    setState(() {
      if (_currentTemp > _minTemp) {
        _currentTemp -= 1.0;
      }
    });
  }

  List<Color> get _gradientColors {
    double t = (_currentTemp - _minTemp) / (_maxTemp - _minTemp);

    return [
      Color.lerp(const Color(0xFF6DD5FA), const Color(0xFFFF7E5F), t)!, 
      Color.lerp(const Color(0xFF86FDE8), const Color(0xFFFFB75E), t)!, 
      Color.lerp(const Color(0xFFA5E68C), const Color(0xFFFEE140), t)!, 
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const HeaderSection(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const TitleSection(),
                    const SizedBox(height: 40),
                    TemperatureIndicator(
                      temp: _currentTemp,
                      gradientColors: _gradientColors,
                    ),
                    const SizedBox(height: 30),
                    CurrentTempSection(currentTemp: _currentTemp),
                    const SizedBox(height: 40),
                    ControlButtons(
                      onDecrease: _decreaseTemp,
                      onIncrease: _increaseTemp,
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const CustomBottomNavBar(activeIndex: 0),
    );
  }
}

class TitleSection extends StatelessWidget {
  const TitleSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Temperatura',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w400,
            color: Color(0xFF2D2D2D),
          ),
        ),
        Icon(Icons.notifications_none, color: Colors.grey[600], size: 28),
      ],
    );
  }
}

class TemperatureIndicator extends StatelessWidget {
  final double temp;
  final List<Color> gradientColors;

  const TemperatureIndicator({
    super.key, 
    required this.temp, 
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ],
          ),
        ),
        Container(
          width: 160,
          height: 160,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F7),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${temp.toInt()}°C',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w400,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CurrentTempSection extends StatelessWidget {
  final double currentTemp;

  const CurrentTempSection({super.key, required this.currentTemp});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Aktualna temperatura',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.arrow_drop_down, color: Colors.grey, size: 30),
            Text(
              '${currentTemp.toInt()}°C',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2D2D2D),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ControlButtons extends StatelessWidget {
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const ControlButtons({
    super.key, 
    required this.onDecrease, 
    required this.onIncrease
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _controlButton(Icons.remove, onDecrease),
        const SizedBox(width: 20),
        _controlButton(Icons.add, onIncrease),
      ],
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Icon(icon, size: 32, color: Colors.black87),
        ),
      ),
    );
  }
}