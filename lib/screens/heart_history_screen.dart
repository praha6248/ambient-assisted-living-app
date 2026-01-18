import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class HeartHistoryScreen extends StatefulWidget {
  const HeartHistoryScreen({super.key});

  @override
  State<HeartHistoryScreen> createState() => _HeartHistoryScreenState();
}

class _HeartHistoryScreenState extends State<HeartHistoryScreen> {
  final List<int> weeklyData = List.generate(7, (index) => 60 + Random().nextInt(40));
  
  final List<String> days = ['P', 'W', 'Ś', 'C', 'P', 'S', 'N'];

  int touchedIndex = 6;

  final Color mainPink = const Color(0xFFFF669D);    
  final Color lightPink = const Color(0xFFFFCCDE);   

  @override
  Widget build(BuildContext context) {
    final double average = weeklyData.reduce((a, b) => a + b) / weeklyData.length;
    final int minBpm = weeklyData.reduce(min);
    final int maxBpm = weeklyData.reduce(max);

    final List<FlSpot> spots = List.generate(7, (index) {
      return FlSpot(index.toDouble(), weeklyData[index].toDouble());
    });

    final LineChartBarData lineChartBarData = LineChartBarData(
      spots: spots,
      isCurved: false,
      color: mainPink,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          if (index == touchedIndex) {
            return FlDotCirclePainter(
              radius: 8,
              color: mainPink,
              strokeWidth: 5,
              strokeColor: lightPink,
            );
          }
          return FlDotCirclePainter(
            radius: 4,
            color: mainPink,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(show: false),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), 
      body: SafeArea(
        child: Column(
          children: [
            Padding(
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
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black87),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      ' Tętno',
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(24, 10, 24, 40),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
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
                        const Text('Październik 18-25', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Row(
                          children: [
                            _iconBtn(Icons.share_outlined),
                            const SizedBox(width: 10),
                            _iconBtn(Icons.download_outlined),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 20),

                    const Text('Średnia:', style: TextStyle(color: Colors.grey, fontSize: 14)),
                    Row(
                      children: [
                        Text(
                          average.toInt().toString(),
                          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w500, color: Color(0xFF2D2D2D)),
                        ),
                        const SizedBox(width: 8),
                        const Text('BPM', style: TextStyle(fontSize: 20, color: Color(0xFF2D2D2D))),
                        const SizedBox(width: 8),
                        const Icon(Icons.favorite, color: Colors.green, size: 24),
                      ],
                    ),
                    Text(
                      'Min: $minBpm BPM  |  Max: $maxBpm BPM',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),

                    const SizedBox(height: 40),

                    Expanded(
                      child: LineChart(
                        LineChartData(
                          showingTooltipIndicators: touchedIndex != -1 
                            ? [
                                ShowingTooltipIndicators(
                                  [
                                    LineBarSpot(
                                      lineChartBarData,
                                      0,
                                      lineChartBarData.spots[touchedIndex],
                                    ),
                                  ],
                                )
                              ] 
                            : [],
                          
                          lineTouchData: LineTouchData(
                            enabled: true,
                            
                            handleBuiltInTouches: false, 
                            
                            touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                              if (response?.lineBarSpots != null && response!.lineBarSpots!.isNotEmpty) {
                                final spotIndex = response.lineBarSpots![0].spotIndex;
                                if (touchedIndex != spotIndex) {
                                  setState(() {
                                    touchedIndex = spotIndex;
                                  });
                                }
                              }
                            },
                            
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipColor: (touchedSpot) => lightPink,
                              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              tooltipMargin: 40,
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((LineBarSpot touchedSpot) {
                                  return LineTooltipItem(
                                    '${touchedSpot.y.toInt()} BPM',
                                    const TextStyle(
                                      color: Colors.black87, 
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                            getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                              return spotIndexes.map((spotIndex) {
                                return TouchedSpotIndicatorData(
                                  FlLine(
                                    color: lightPink,
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
                            getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 20,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0 || value > 130) return const SizedBox(); 
                                  return Text(
                                    value.toInt().toString(), 
                                    style: const TextStyle(color: Colors.grey, fontSize: 11)
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
                                    bool isSelected = (index == touchedIndex);
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Container(
                                        width: 32,
                                        height: 32, 
                                        alignment: Alignment.center,
                                        decoration: isSelected 
                                          ? BoxDecoration(
                                              color: lightPink, 
                                              shape: BoxShape.circle,
                                            )
                                          : null,
                                        child: Text(
                                          days[index],
                                          style: TextStyle(
                                            color: isSelected ? Colors.black87 : Colors.grey,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
                          lineBarsData: [
                            lineChartBarData,
                          ],
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
  }

  Widget _textButton(String text) {
    return Text(
      text, 
      style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)
    );
  }

  Widget _iconBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.black54, size: 20),
    );
  }
}