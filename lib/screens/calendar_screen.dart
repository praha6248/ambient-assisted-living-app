import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/common_widgets.dart';
import '../widgets/notification_bell.dart'; 
import '../services/notification_service.dart';
import '../services/local_notifications.dart';

enum RecurrenceType { none, daily, weekly, monthly }

class CalendarEvent {
  final String title;
  final TimeOfDay time;
  final RecurrenceType recurrence; 
  
  CalendarEvent(this.title, this.time, {this.recurrence = RecurrenceType.none});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'hour': time.hour,
      'minute': time.minute,
      'recurrence': recurrence.index,
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      json['title'],
      TimeOfDay(hour: json['hour'], minute: json['minute']),
      recurrence: RecurrenceType.values[json['recurrence'] ?? 0],
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<CalendarEvent>> _events = {};

  final Color mainPink = const Color(0xFFFF669D);

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents(); 
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> encodedMap = {};
    _events.forEach((key, value) {
      String dateKey = key.toIso8601String(); 
      encodedMap[dateKey] = value.map((e) => e.toJson()).toList();
    });
    await prefs.setString('calendar_events', jsonEncode(encodedMap));
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final String? eventsString = prefs.getString('calendar_events');

    if (eventsString != null) {
      Map<String, dynamic> decodedMap = jsonDecode(eventsString);
      Map<DateTime, List<CalendarEvent>> newEvents = {};
      decodedMap.forEach((key, value) {
        DateTime dateKey = DateTime.parse(key);
        List<dynamic> list = value;
        newEvents[dateKey] = list.map((e) => CalendarEvent.fromJson(e)).toList();
      });
      setState(() {
        _events = newEvents;
      });
    } else {
      _addEvent(DateTime.now(), "Wizyta u kardiologa", const TimeOfDay(hour: 14, minute: 30), RecurrenceType.none);
    }
  }

  void _addEvent(DateTime date, String title, TimeOfDay time, RecurrenceType recurrence) {
    void addSingleEvent(DateTime d) {
      final dateKey = DateTime(d.year, d.month, d.day);
      if (_events[dateKey] == null) _events[dateKey] = [];
      _events[dateKey]!.add(CalendarEvent(title, time, recurrence: recurrence));
    }

    if (recurrence == RecurrenceType.none) {
      addSingleEvent(date);
    } else if (recurrence == RecurrenceType.daily) {
      for (int i = 0; i < 30; i++) addSingleEvent(date.add(Duration(days: i)));
    } else if (recurrence == RecurrenceType.weekly) {
      for (int i = 0; i < 12; i++) addSingleEvent(date.add(Duration(days: i * 7)));
    } else if (recurrence == RecurrenceType.monthly) {
      for (int i = 0; i < 12; i++) addSingleEvent(DateTime(date.year, date.month + i, date.day));
    }
    
    _saveEvents(); 
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
  }

  String _formatTime24(TimeOfDay time) {
    final hour = time.hour.toString();
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getRecurrenceLabel(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.daily: return "Codziennie";
      case RecurrenceType.weekly: return "Co tydzień";
      case RecurrenceType.monthly: return "Co miesiąc";
      default: return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: const CustomBottomNavBar(activeIndex: 3),
      
      body: SafeArea(
        child: Column(
          children: [
            const HeaderSection(), 
            
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kalendarz',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: Color(0xFF2D2D2D)),
                          ),
                          NotificationBell(), 
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
                        ],
                      ),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 10, 16),
                        lastDay: DateTime.utc(2030, 3, 14),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        locale: 'pl_PL',
                        calendarStyle: CalendarStyle(
                          todayDecoration: const BoxDecoration(color: Color(0xFFFFCCDE), shape: BoxShape.circle),
                          selectedDecoration: BoxDecoration(color: mainPink, shape: BoxShape.circle),
                          markerDecoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                        ),
                        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                        eventLoader: _getEventsForDay,
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Przypomnienia na ${_selectedDay?.day}.${_selectedDay?.month}",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
                          ),
                          GestureDetector(
                            onTap: _showAddEventDialog,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                              child: const Icon(Icons.add, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _getEventsForDay(_selectedDay!).length,
                      itemBuilder: (context, index) {
                        final event = _getEventsForDay(_selectedDay!)[index];
                        final isRecurrent = event.recurrence != RecurrenceType.none;
                        
                        // --- ZMIANA: Dodano GestureDetector do edycji ---
                        return GestureDetector(
                          onTap: () {
                            _showEditEventDialog(event, index);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade100),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isRecurrent ? const Color(0xFFFFF0F5) : const Color(0xFFE0F7FA),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isRecurrent ? Icons.repeat : Icons.access_time_filled, 
                                    color: isRecurrent ? mainPink : const Color(0xFF00ACC1),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      Row(
                                        children: [
                                          Text(_formatTime24(event.time), style: const TextStyle(color: Colors.grey)),
                                          if (isRecurrent) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                _getRecurrenceLabel(event.recurrence),
                                                style: TextStyle(fontSize: 10, color: mainPink, fontWeight: FontWeight.bold),
                                              ),
                                            )
                                          ]
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEventDialog() {
    String newTitle = "";
    TimeOfDay newTime = TimeOfDay.now();
    RecurrenceType selectedRecurrence = RecurrenceType.none;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Nowe przypomnienie"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Co masz do zrobienia?",
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: mainPink, width: 2)),
                      border: const OutlineInputBorder(),
                    ),
                    cursorColor: mainPink,
                    onChanged: (val) => newTitle = val,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Godzina: ${_formatTime24(newTime)}", style: const TextStyle(fontSize: 16)),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: mainPink),
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: newTime,
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: ColorScheme.light(primary: mainPink, onPrimary: Colors.white, onSurface: Colors.black),
                                  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: mainPink)),
                                ),
                                child: MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
                              );
                            },
                          );
                          if (picked != null) setStateDialog(() => newTime = picked);
                        },
                        child: const Text("Zmień"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Powtarzanie:", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  DropdownButtonFormField<RecurrenceType>(
                    value: selectedRecurrence,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: mainPink),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: RecurrenceType.none, child: Text("Jednorazowo")),
                      DropdownMenuItem(value: RecurrenceType.daily, child: Text("Codziennie")),
                      DropdownMenuItem(value: RecurrenceType.weekly, child: Text("Co tydzień")),
                      DropdownMenuItem(value: RecurrenceType.monthly, child: Text("Co miesiąc")),
                    ],
                    onChanged: (RecurrenceType? newValue) {
                      setStateDialog(() => selectedRecurrence = newValue!);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  child: const Text("Anuluj"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: mainPink),
                  onPressed: () async {
                    if (newTitle.isNotEmpty && _selectedDay != null) {
                      setState(() {
                        _addEvent(_selectedDay!, newTitle, newTime, selectedRecurrence);
                      });
                      
                      Navigator.pop(context);

                      DateTime scheduledDate = DateTime(
                        _selectedDay!.year, _selectedDay!.month, _selectedDay!.day,
                        newTime.hour, newTime.minute,
                      );
                      if (scheduledDate.isBefore(DateTime.now())) {
                         scheduledDate = scheduledDate.add(const Duration(days: 1));
                      }

                      await LocalNotifications.scheduleNotification(
                        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                        title: "Przypomnienie SmartHelp",
                        body: "Czas na: $newTitle",
                        scheduledDate: scheduledDate,
                      );

                      await NotificationService().addNotification(
                        "Zaplanowano: $newTitle",
                        _formatTime24(newTime),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Przypomnienie dodane!")),
                      );
                    }
                  },
                  child: const Text("Dodaj", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditEventDialog(CalendarEvent event, int index) {
    String newTitle = event.title;
    TimeOfDay newTime = event.time;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Edytuj przypomnienie"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: TextEditingController(text: newTitle),
                    decoration: InputDecoration(
                      labelText: "Co masz do zrobienia?",
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: mainPink, width: 2)),
                      border: const OutlineInputBorder(),
                    ),
                    cursorColor: mainPink,
                    onChanged: (val) => newTitle = val,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Godzina: ${_formatTime24(newTime)}", style: const TextStyle(fontSize: 16)),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: mainPink),
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: newTime,
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: ThemeData.light().copyWith(
                                  colorScheme: ColorScheme.light(primary: mainPink, onPrimary: Colors.white, onSurface: Colors.black),
                                  textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: mainPink)),
                                ),
                                child: MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child!),
                              );
                            },
                          );
                          if (picked != null) setStateDialog(() => newTime = picked);
                        },
                        child: const Text("Zmień"),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (_selectedDay != null) {
                      setState(() {
                        final dateKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                        if (_events[dateKey] != null) {
                          _events[dateKey]!.removeAt(index);
                          if (_events[dateKey]!.isEmpty) {
                            _events.remove(dateKey);
                          }
                        }
                      });
                      _saveEvents(); 
                      Navigator.pop(context); 
                    }
                  },
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text("Usuń"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: mainPink),
                  onPressed: () async {
                    if (newTitle.isNotEmpty && _selectedDay != null) {
                      setState(() {
                        final dateKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
                        if (_events[dateKey] != null) {
                          _events[dateKey]![index] = CalendarEvent(
                            newTitle, 
                            newTime, 
                            recurrence: event.recurrence
                          );
                        }
                      });
                      
                      _saveEvents(); 
                      Navigator.pop(context);

                      await NotificationService().addNotification(
                        "Zaktualizowano: $newTitle",
                        _formatTime24(newTime),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Zmiany zapisane!")),
                      );
                    }
                  },
                  child: const Text("Zapisz", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}