import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import '../services/theme_service.dart';

class HistoryEvent {
  final String time;
  final String title;
  final bool isAlert;

  HistoryEvent({
    required this.time,
    required this.title,
    required this.isAlert,
  });
}

class HistorySection {
  final String dateLabel;
  bool isExpanded;
  final List<HistoryEvent> events;

  HistorySection({
    required this.dateLabel,
    this.isExpanded = true,
    required this.events,
  });
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<HistorySection> _sections = [
    HistorySection(
      dateLabel: "Dzisiaj",
      isExpanded: true,
      events: [
        HistoryEvent(time: "09:45", title: "Wykryto upadek krytyczny!", isAlert: true),
        HistoryEvent(time: "09:40", title: "Wykryto upadek", isAlert: true),
      ],
    ),
    HistorySection(
      dateLabel: "Wczoraj",
      isExpanded: false,
      events: [
        HistoryEvent(time: "18:20", title: "Wykryto upadek krytyczny!", isAlert: true),
        HistoryEvent(time: "12:10", title: "Wykryto upadek", isAlert: true),
      ],
    ),
    HistorySection(
      dateLabel: "17 stycznia",
      isExpanded: false,
      events: [
        HistoryEvent(time: "20:15", title: "Wykryto upadek krytyczny!", isAlert: true),
        HistoryEvent(time: "15:30", title: "Wykryto upadek", isAlert: true),
      ],
    ),
  ];

  void _toggleSection(int index) {
    setState(() {
      _sections[index].isExpanded = !_sections[index].isExpanded;
    });
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
                  title: 'Aktywność',
                  showChartIcon: false,
                ),
                
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 120.0),
                    itemCount: _sections.length,
                    itemBuilder: (context, index) {
                      final section = _sections[index];
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () => _toggleSection(index),
                            child: Container(
                              color: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isHighContrast ? Colors.black : const Color(0xFFF4F1F2),
                                      shape: BoxShape.circle,
                                      border: isHighContrast ? Border.all(color: Colors.yellow) : null,
                                    ),
                                    child: Icon(
                                      section.isExpanded 
                                          ? Icons.keyboard_arrow_down 
                                          : Icons.keyboard_arrow_right, 
                                      size: 24, 
                                      color: isHighContrast ? Colors.yellow : Colors.black54
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    section.dateLabel,
                                    style: TextStyle(
                                      fontSize: 20, 
                                      fontWeight: FontWeight.w500, 
                                      color: isHighContrast ? Colors.yellow : const Color(0xFF2D2D2D)
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (section.isExpanded)
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: section.events.length,
                              itemBuilder: (ctx, eventIndex) {
                                final event = section.events[eventIndex];
                                
                                final isFirst = eventIndex == 0;
                                final isLast = eventIndex == section.events.length - 1;
                                
                                return _buildTimelineItem(
                                  time: event.time,
                                  title: event.title,
                                  isAlert: event.isAlert,
                                  isFirst: isFirst,
                                  isLast: isLast,
                                  isHighContrast: isHighContrast,
                                );
                              },
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: const CustomBottomNavBar(activeIndex: 4),
        );
      }
    );
  }

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required bool isAlert,
    required bool isFirst,
    required bool isLast,
    required bool isHighContrast,
  }) {
    // --- KOLORY ---
    final dotColor = const Color(0xFF5151FB); // Ciemny niebieski (kropka)
    final lineColor = const Color(0xFFC8297FC); // Jasny błękit (linia/otoczka)
    
    final alertColor = const Color(0xFFEB4755); // Czerwony (Alert)
    final infoColor = const Color(0xFF148FB8);  // Niebieski (Info)

    // Odległość od góry do środka kropki (margin 4 + połowa wysokości 16)
    const double topOffset = 12.0;

    return IntrinsicHeight(
      child: Row(
        // KLUCZOWE: Stretch sprawia, że linia rozciąga się na całą wysokość elementu
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isHighContrast ? Colors.yellow : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: isHighContrast ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: isHighContrast ? Border.all(color: Colors.yellow, width: 1) : null,
                    boxShadow: [
                      if (!isHighContrast)
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            color: isHighContrast 
                                ? Colors.yellow 
                                : (isAlert ? alertColor : infoColor),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  Icon(
                                    isAlert ? Icons.warning_amber_rounded : Icons.info_outline,
                                    color: isHighContrast 
                                        ? Colors.yellow 
                                        : (isAlert ? alertColor : infoColor),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: isHighContrast ? Colors.yellow : const Color(0xFF2D2D2D),
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}