import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/theme_service.dart';
import '../connection/pomiar_model.dart';
import '../services/pomiar_service.dart';

class HeartHistoryScreen extends StatefulWidget {
  const HeartHistoryScreen({super.key});

  @override
  State<HeartHistoryScreen> createState() => _HeartHistoryScreenState();
}

class _HeartHistoryScreenState extends State<HeartHistoryScreen> {
  final List<String> days = ['P', 'W', 'Ś', 'C', 'P', 'S', 'N'];

  int touchedIndex = 6;

  final Color mainPink = const Color(0xFFFF3344);
  final Color lightPink = const Color(0xFFFFB2B9);

  @override
  Widget build(BuildContext context) {
    // 1. Pobieranie danych z modelu
    final List<Pomiar> historiaPomiary = PomiarService.getPomiary();

    // 2. Wyciągnięcie samych wartości tętna z obiektów do szybkiej matematyki
    final List<int> wartosciTetna = historiaPomiary
        .map((p) => p.tetno)
        .toList();

    // 3. Dynamiczne statystyki na bazie modelu
    final double average =
        wartosciTetna.reduce((a, b) => a + b) / wartosciTetna.length;
    final int minBpm = wartosciTetna.reduce(min);
    final int maxBpm = wartosciTetna.reduce(max);

    // 4. Generowanie punktów dla wykresu (FlSpot)
    final List<FlSpot> spots = List.generate(historiaPomiary.length, (index) {
      return FlSpot(index.toDouble(), historiaPomiary[index].tetno.toDouble());
    });

    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isHighContrast,
      builder: (context, isHighContrast, child) {
        final Color mainColor = isHighContrast ? Colors.yellow : mainPink;
        final Color secColor = isHighContrast ? Colors.yellow : lightPink;
        final Color bgColor = isHighContrast
            ? Colors.black
            : const Color(0xFFF5F5F7);
        final Color textColor = isHighContrast
            ? Colors.yellow
            : const Color(0xFF2D2D2D);
        final Color subTextColor = isHighContrast ? Colors.yellow : Colors.grey;

        final LineChartBarData lineChartBarData = LineChartBarData(
          spots: spots, // Przekazanie punktów do wykresu
          isCurved: false,
          color: mainColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              if (index == touchedIndex) {
                return FlDotCirclePainter(
                  radius: 8,
                  color: mainColor,
                  strokeWidth: 5,
                  strokeColor: secColor,
                );
              }
              return FlDotCirclePainter(
                radius: 4,
                color: mainColor,
                strokeWidth: 2,
                strokeColor: isHighContrast ? Colors.black : Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(show: false),
        );

        return Scaffold(
          backgroundColor: bgColor,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: isHighContrast
                              ? Colors.yellow
                              : Colors.black87,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          ' Tętno',
                          style: TextStyle(
                            fontSize: 18,
                            color: isHighContrast
                                ? Colors.yellow
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isHighContrast ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: isHighContrast
                          ? Border.all(color: Colors.yellow, width: 2)
                          : null,
                      boxShadow: [
                        if (!isHighContrast)
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ostatnie pomiary',
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 14,
                              ),
                            ),
                            Row(
                              children: [
                                _iconBtn(Icons.share_outlined, isHighContrast),
                                const SizedBox(width: 10),
                                _iconBtn(
                                  Icons.download_outlined,
                                  isHighContrast,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'Średnia:',
                          style: TextStyle(color: subTextColor, fontSize: 14),
                        ),
                        Row(
                          children: [
                            Text(
                              average
                                  .toInt()
                                  .toString(), // Wyświetlanie średniej
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'BPM',
                              style: TextStyle(fontSize: 20, color: textColor),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.favorite,
                              color: isHighContrast
                                  ? Colors.yellow
                                  : Colors.green,
                              size: 24,
                            ),
                          ],
                        ),
                        Text(
                          'Min: $minBpm BPM  |  Max: $maxBpm BPM', // Wyświetlanie min i max
                          style: TextStyle(color: subTextColor, fontSize: 12),
                        ),

                        const SizedBox(height: 40),

                        Expanded(
                          child: LineChart(
                            LineChartData(
                              showingTooltipIndicators: touchedIndex != -1
                                  ? [
                                      ShowingTooltipIndicators([
                                        LineBarSpot(
                                          lineChartBarData,
                                          0,
                                          lineChartBarData.spots[touchedIndex],
                                        ),
                                      ]),
                                    ]
                                  : [],

                              lineTouchData: LineTouchData(
                                enabled: true,
                                handleBuiltInTouches: false,
                                touchCallback:
                                    (
                                      FlTouchEvent event,
                                      LineTouchResponse? response,
                                    ) {
                                      if (response?.lineBarSpots != null &&
                                          response!.lineBarSpots!.isNotEmpty) {
                                        final spotIndex =
                                            response.lineBarSpots![0].spotIndex;
                                        if (touchedIndex != spotIndex) {
                                          setState(() {
                                            touchedIndex = spotIndex;
                                          });
                                        }
                                      }
                                    },

                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipColor: (touchedSpot) => secColor,
                                  tooltipPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  tooltipMargin: 40,
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((
                                      LineBarSpot touchedSpot,
                                    ) {
                                      return LineTooltipItem(
                                        '${touchedSpot.y.toInt()} BPM',
                                        const TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                                getTouchedSpotIndicator:
                                    (
                                      LineChartBarData barData,
                                      List<int> spotIndexes,
                                    ) {
                                      return spotIndexes.map((spotIndex) {
                                        return TouchedSpotIndicatorData(
                                          FlLine(
                                            color: secColor,
                                            strokeWidth: 3,
                                            dashArray: [6, 4],
                                          ),
                                          FlDotData(show: false),
                                        );
                                      }).toList();
                                    },
                              ),

                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                horizontalInterval: 20,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: isHighContrast
                                      ? Colors.yellow.withOpacity(0.3)
                                      : Colors.grey.shade200,
                                  strokeWidth: 1,
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 20,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      if (value == 0 || value > 130)
                                        return const SizedBox();
                                      return Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                          color: subTextColor,
                                          fontSize: 11,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      int index = value.toInt();
                                      if (index >= 0 && index < days.length) {
                                        bool isSelected =
                                            (index == touchedIndex);
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            top: 10.0,
                                          ),
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            alignment: Alignment.center,
                                            decoration: isSelected
                                                ? BoxDecoration(
                                                    color: secColor,
                                                    shape: BoxShape.circle,
                                                  )
                                                : null,
                                            child: Text(
                                              days[index],
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.black87
                                                    : subTextColor,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              minX: 0,
                              maxX: 6,
                              minY: 40,
                              maxY: 140,
                              lineBarsData: [lineChartBarData],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _iconBtn(IconData icon, bool isHighContrast) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isHighContrast ? Colors.black : Colors.grey.shade100,
        shape: BoxShape.circle,
        border: isHighContrast ? Border.all(color: Colors.yellow) : null,
      ),
      child: Icon(
        icon,
        color: isHighContrast ? Colors.yellow : Colors.black54,
        size: 20,
      ),
    );
  }
}
