import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import '../services/theme_service.dart';

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
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isHighContrast,
      builder: (context, isHighContrast, child) {
        return Scaffold(
          backgroundColor: isHighContrast ? Colors.black : const Color(0xFFF4F1F2),
          body: SafeArea(
            child: Column(
              children: [
                HeaderSection(
                  title: 'Temperatura',
                  showChartIcon: false, 
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
                        
                        TemperatureIndicator(
                          temp: _targetTemp,
                          gradientColors: _gradientColors,
                          isHighContrast: isHighContrast,
                        ),
                        
                        const SizedBox(height: 30),
                        
                        CurrentTempSection(
                          roomTemp: _roomTemp, 
                          targetTemp: _targetTemp,
                          isHighContrast: isHighContrast,
                        ),
                        
                        const SizedBox(height: 40),
                        ControlButtons(
                          onDecrease: _decreaseTemp,
                          onIncrease: _increaseTemp,
                          isHighContrast: isHighContrast,
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
    );
  }
}

class TemperatureIndicator extends StatelessWidget {
  final double temp;
  final List<Color> gradientColors;
  final bool isHighContrast;

  const TemperatureIndicator({
    super.key,
    required this.temp,
    required this.gradientColors,
    required this.isHighContrast,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isHighContrast 
              ? null 
              : LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: gradientColors,
                ),
            color: isHighContrast ? Colors.black : null,
            border: isHighContrast ? Border.all(color: Colors.yellow, width: 4) : null,
          ),
        ),
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            color: isHighContrast ? Colors.black : const Color(0xFFF5F5F7),
            shape: BoxShape.circle,
            border: isHighContrast ? Border.all(color: Colors.yellow, width: 2) : null,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Cel", 
                  style: TextStyle(
                    fontSize: 12, 
                    color: isHighContrast ? Colors.yellow : Colors.grey
                  )
                ),
                Text(
                  '${temp.toInt()}°C',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w400,
                    color: isHighContrast ? Colors.yellow : const Color(0xFF2D2D2D),
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
  final bool isHighContrast;

  const CurrentTempSection({
    super.key, 
    required this.roomTemp, 
    required this.targetTemp,
    required this.isHighContrast,
  });

  @override
  Widget build(BuildContext context) {
    IconData? statusIcon;
    Color statusColor = Colors.grey;

    if (targetTemp > roomTemp) {
      statusIcon = Icons.arrow_drop_up;
      statusColor = isHighContrast ? Colors.yellow : Colors.orangeAccent;
    } else if (targetTemp < roomTemp) {
      statusIcon = Icons.arrow_drop_down;
      statusColor = isHighContrast ? Colors.yellow : Colors.lightBlue; 
    } else {
      statusIcon = null; 
    }

    return Column(
      children: [
        Text(
          'Temperatura w pokoju',
          style: TextStyle(
            color: isHighContrast ? Colors.yellow : Colors.grey, 
            fontSize: 16
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (statusIcon != null)
              Icon(statusIcon, color: statusColor, size: 40)
            else
              Icon(
                Icons.check_circle_outline, 
                color: isHighContrast ? Colors.yellow : Colors.green, 
                size: 24
              ),

            const SizedBox(width: 8),
            
            Text(
              '${roomTemp.toInt()}°C',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w500,
                color: isHighContrast ? Colors.yellow : const Color(0xFF2D2D2D),
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
  final bool isHighContrast;

  const ControlButtons({
    super.key,
    required this.onDecrease,
    required this.onIncrease,
    required this.isHighContrast,
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
            color: isHighContrast ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: isHighContrast ? Border.all(color: Colors.yellow, width: 2) : null,
            boxShadow: [
              if (!isHighContrast)
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
            ],
          ),
          child: Icon(
            icon, 
            size: 32, 
            color: isHighContrast ? Colors.yellow : Colors.black87
          ),
        ),
      ),
    );
  }
}