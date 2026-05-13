import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/common_widgets.dart';
import 'blood_saturation_history_screen.dart';
import '../services/theme_service.dart';

class BloodSaturationScreen extends StatelessWidget {
  const BloodSaturationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isHighContrast,
      builder: (context, isHighContrast, child) {
        final bgColor = isHighContrast ? Colors.black : const Color(0xFFF4F1F2);

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                // Ujednolicony HeaderSection (taki sam jak w heart_screen)
                HeaderSection(
                  title: 'Nasycenie krwi',
                  showChartIcon: true,
                  onHistoryTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const BloodSaturationHistoryScreen(),
                      ),
                    );
                  },
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        SaturationIndicator(isHighContrast: isHighContrast),
                        const SizedBox(height: 20),
                        ResultValue(isHighContrast: isHighContrast),
                        const SizedBox(height: 30),
                        StatusCard(isHighContrast: isHighContrast),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: const CustomBottomNavBar(activeIndex: 0),
        );
      },
    );
  }
}

class SaturationIndicator extends StatelessWidget {
  final bool isHighContrast;
  const SaturationIndicator({super.key, required this.isHighContrast});

  @override
  Widget build(BuildContext context) {
    const Color dropBlue = Color(0xFF4B93D1);

    if (isHighContrast) {
      return SizedBox(
        width: 170,
        height: 170,
        child: Center(
          child: SvgPicture.asset(
            'assets/sat.svg',
            width: 140,
            colorFilter: const ColorFilter.mode(Colors.yellow, BlendMode.srcIn),
          ),
        ),
      );
    }

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFCDE4F7),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFCDE4F7).withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            color: Color(0xFF8BC0E9),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(22.0),
          child: SvgPicture.asset(
            'assets/sat.svg',
            colorFilter: const ColorFilter.mode(dropBlue, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

class ResultValue extends StatelessWidget {
  final bool isHighContrast;
  const ResultValue({super.key, required this.isHighContrast});

  @override
  Widget build(BuildContext context) {
    final mainColor = isHighContrast ? Colors.yellow : const Color(0xFF2D2D2D);
    final subColor = isHighContrast ? Colors.yellow : const Color(0xFF555555);

    return Column(
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '98',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w400,
                  color: mainColor,
                  height: 1.0,
                ),
              ),
              TextSpan(
                text: ' %',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                  color: subColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: isHighContrast ? Colors.yellow : const Color(0xFF4B93D1),
            ),
            const SizedBox(width: 4),
            Text(
              '5 minut temu',
              style: TextStyle(
                color: isHighContrast ? Colors.yellow : Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StatusCard extends StatelessWidget {
  final bool isHighContrast;
  const StatusCard({super.key, required this.isHighContrast});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isHighContrast ? Colors.black : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isHighContrast
            ? Border.all(color: Colors.yellow, width: 2)
            : null,
        boxShadow: isHighContrast
            ? []
            : [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'twoje nasycenie krwi jest',
            style: TextStyle(
              color: isHighContrast ? Colors.yellow : Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'w normie',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: isHighContrast
                      ? Colors.yellow
                      : const Color(0xFF2D2D2D),
                ),
              ),
              const SizedBox(width: 8),
              SvgPicture.asset(
                'assets/sat.svg',
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(
                  isHighContrast ? Colors.yellow : const Color(0xFF1B8E3B),
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),

          Center(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '90-100', // Prawidłowa norma SpO2
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w400,
                      color: isHighContrast
                          ? Colors.yellow
                          : const Color(0xFF2D2D2D),
                    ),
                  ),
                  TextSpan(
                    text: ' %',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isHighContrast
                          ? Colors.yellow
                          : const Color(0xFF2D2D2D),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Nowy pasek zaadaptowany z heart_screen
          _CustomSpO2BarGauge(
            isHighContrast: isHighContrast,
            activeColor: const Color(0xFF4B93D1), // Niebieski dla SpO2
          ),
        ],
      ),
    );
  }
}

// --- KLASY DLA PASKA ---

class _CustomSpO2BarGauge extends StatelessWidget {
  final bool isHighContrast;
  final Color activeColor;

  const _CustomSpO2BarGauge({
    required this.isHighContrast,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final barColor = isHighContrast ? Colors.yellow : activeColor;
    final bgColor = isHighContrast
        ? Colors.grey.shade900
        : const Color(0xFFE0E0E0);
    final dottedColor = isHighContrast ? Colors.black : Colors.white;
    final sideTextColor = isHighContrast ? Colors.yellow : Colors.grey;

    return Column(
      children: [
        SizedBox(
          height: 30,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Tło paska
              Container(
                height: 24,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: bgColor,
                  border: isHighContrast
                      ? Border.all(color: Colors.yellow)
                      : null,
                ),
              ),

              // Wypełniony pasek (przesunięty na prawą stronę dla 98%)
              Align(
                alignment: const Alignment(0.85, 0.0),
                child: Container(
                  height: 24,
                  width: 100,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: CustomPaint(
                      size: const Size(1, 24),
                      painter: _DottedLineSpO2Painter(color: dottedColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('70', style: TextStyle(color: sideTextColor, fontSize: 12)),
            Text(
              "98\nOstatni pomiar",
              textAlign: TextAlign.center,
              style: TextStyle(color: barColor, fontSize: 10),
            ),
            Text('100', style: TextStyle(color: sideTextColor, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _DottedLineSpO2Painter extends CustomPainter {
  final Color color;
  _DottedLineSpO2Painter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + 3), paint);
      startY += 5;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
