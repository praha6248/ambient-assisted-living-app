import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import '../widgets/notification_bell.dart';

class TemperatureScreen extends StatefulWidget {
  const TemperatureScreen({super.key});

  @override
  State<TemperatureScreen> createState() => _TemperatureScreenState();
}

class _TemperatureScreenState extends State<TemperatureScreen> {
  double _targetTemp = 22.0; 
  
  final double _roomTemp = 20.0; 

  final double _minTemp = 16.0;
  final double _maxTemp = 28.0;

  final Color _colBlue = const Color(0xFF4FACFE);
  final Color _colCyan = const Color(0xFF00F2FE);
  final Color _colGreen = const Color(0xFF66FF99);
  final Color _colYellow = const Color(0xFFFEE140);
  final Color _colOrange = const Color(0xFFFF7E5F);

  void _increaseTemp() {
    setState(() {
      if (_targetTemp < _maxTemp) {
        _targetTemp += 1.0;
      }
    });
  }

  void _decreaseTemp() {
    setState(() {
      if (_targetTemp > _minTemp) {
        _targetTemp -= 1.0;
      }
    });
  }

  Color _getInterpolatedColor(double temp, List<Color> colors) {
    double t;
    if (temp <= 20.0) {
      t = (temp - 16.0) / 4.0;
      return Color.lerp(colors[0], colors[1], t)!;
    } else if (temp <= 24.0) {
      t = (temp - 20.0) / 4.0;
      return Color.lerp(colors[1], colors[2], t)!;
    } else {
      t = (temp - 24.0) / 4.0;
      t = t.clamp(0.0, 1.0); 
      return Color.lerp(colors[2], colors[3], t)!;
    }
  }

  List<Color> get _gradientColors {
    List<Color> bottomPath = [_colBlue, _colCyan, _colGreen, _colYellow];
    List<Color> topPath = [_colCyan, _colGreen, _colYellow, _colOrange];

    return [
      _getInterpolatedColor(_targetTemp, bottomPath),
      _getInterpolatedColor(_targetTemp, topPath),
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
                      temp: _targetTemp,
                      gradientColors: _gradientColors,
                    ),
                    
                    const SizedBox(height: 30),
                    
                    CurrentTempSection(
                      roomTemp: _roomTemp, 
                      targetTemp: _targetTemp
                    ),
                    
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
        const NotificationBell(),
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
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Cel", style: TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  '${temp.toInt()}°C',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CurrentTempSection extends StatelessWidget {
  final double roomTemp;   
  final double targetTemp; 

  const CurrentTempSection({
    super.key, 
    required this.roomTemp, 
    required this.targetTemp
  });

  @override
  Widget build(BuildContext context) {
    IconData? statusIcon;
    Color statusColor = Colors.grey;

    if (targetTemp > roomTemp) {
      statusIcon = Icons.arrow_drop_up;
      statusColor = Colors.orangeAccent;
    } else if (targetTemp < roomTemp) {
      statusIcon = Icons.arrow_drop_down;
      statusColor = Colors.lightBlue; 
    } else {
      statusIcon = null; 
    }

    return Column(
      children: [
        const Text(
          'Temperatura w pokoju',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (statusIcon != null)
              Icon(statusIcon, color: statusColor, size: 40)
            else
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 24),

            const SizedBox(width: 8),
            
            Text(
              '${roomTemp.toInt()}°C',
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
    required this.onIncrease,
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