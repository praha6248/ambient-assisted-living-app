import 'package:flutter/material.dart';
import '../widgets/common_widgets.dart';
import '../widgets/notification_bell.dart';

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
        HistoryEvent(time: "12 min temu", title: "Wykryto upadek", isAlert: true),
        HistoryEvent(time: "08:30", title: "Wzięto leki poranne", isAlert: false),
      ],
    ),
    HistorySection(
      dateLabel: "Wczoraj",
      isExpanded: false,
      events: [
        HistoryEvent(time: "22:00", title: "Brak aktywności (noc)", isAlert: true),
        HistoryEvent(time: "18:45", title: "Spacer zakończony", isAlert: false),
        HistoryEvent(time: "14:20", title: "Pomiar tętna: 78 BPM", isAlert: false),
      ],
    ),
    HistorySection(
      dateLabel: "15.10.2023",
      isExpanded: false,
      events: [
        HistoryEvent(time: "09:00", title: "Wizyta kontrolna", isAlert: false),
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Aktywność',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const NotificationBell(),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

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
                                  color: Colors.grey.shade200,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  section.isExpanded 
                                      ? Icons.keyboard_arrow_down 
                                      : Icons.keyboard_arrow_right, 
                                  size: 24, 
                                  color: Colors.black54
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                section.dateLabel,
                                style: const TextStyle(
                                  fontSize: 20, 
                                  fontWeight: FontWeight.w500, 
                                  color: Color(0xFF2D2D2D)
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
                            final isLast = eventIndex == section.events.length - 1;
                            
                            return _buildTimelineItem(
                              time: event.time,
                              title: event.title,
                              isAlert: event.isAlert,
                              isLast: isLast,
                            );
                          },
                        ),
                      
                      const SizedBox(height: 20),
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

  Widget _buildTimelineItem({
    required String time,
    required String title,
    required bool isAlert,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4, left: 6),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF669D),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      width: 2,
                      color: const Color(0xFFFFCCDE),
                    ),
                  ),
              ],
            ),
          ),
          
          const SizedBox(width: 8), 

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
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
                            color: isAlert ? const Color(0xFFFF5252) : const Color(0xFF6DC6D8),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  Icon(
                                    isAlert ? Icons.warning_amber_rounded : Icons.info_outline,
                                    color: isAlert ? const Color(0xFFFF5252) : const Color(0xFF6DC6D8),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: isAlert ? const Color(0xFF2D2D2D) : Colors.black87,
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

  Widget _textButton(String text) {
    return Text(
      text, 
      style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)
    );
  }
}