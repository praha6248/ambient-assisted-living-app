import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/common_widgets.dart';
import '../widgets/notification_bell.dart'; 
import '../services/notification_service.dart';
import '../services/local_notifications.dart';
import '../services/theme_service.dart';

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
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeService().isHighContrast,
      builder: (context, isHighContrast, child) {
        
        // --- KONFIGURACJA KOLORÓW ---
        final Color bgColor = isHighContrast ? Colors.black : const Color(0xFFF4F1F2);
        final Color cardColor = isHighContrast ? Colors.black : Colors.white;
        final Color textColor = isHighContrast ? Colors.yellow : const Color(0xFF2D2D2D);
        final Color subTextColor = isHighContrast ? Colors.yellow : Colors.black54;

        // Akcenty "Giga Minimalist"
        final Color minimalBlack = const Color(0xFF1E1E1E); 
        final Color accentIndigo = const Color(0xFF5757DB); 
        final Color accentLavender = const Color(0xFFC0C8F2); 
        final Color tagBgColor = const Color(0xFFF5F5F5); 

        return Scaffold(
          backgroundColor: bgColor,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: const CustomBottomNavBar(activeIndex: 3),
          
          body: SafeArea(
            child: Column(
              children: [
                HeaderSection(
                  title: 'Kalendarz',
                  showChartIcon: false,
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          // PADDING OD DOŁU KALENDARZA
                          padding: const EdgeInsets.only(bottom: 12), 
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: isHighContrast ? Border.all(color: Colors.yellow, width: 2) : null,
                            boxShadow: [
                              if (!isHighContrast)
                                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
                            ],
                          ),
                          child: TableCalendar(
                            firstDay: DateTime.utc(2020, 10, 16),
                            lastDay: DateTime.utc(2030, 3, 14),
                            focusedDay: _focusedDay,
                            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                            locale: 'pl_PL',
                            daysOfWeekStyle: DaysOfWeekStyle(
                              weekdayStyle: TextStyle(color: subTextColor),
                              weekendStyle: TextStyle(color: subTextColor),
                            ),
                            calendarStyle: CalendarStyle(
                              defaultTextStyle: TextStyle(color: textColor),
                              weekendTextStyle: TextStyle(color: textColor),
                              outsideTextStyle: TextStyle(color: isHighContrast ? Colors.grey : const Color(0xFFAEAEAE)),
                              
                              todayDecoration: isHighContrast 
                                ? BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.yellow))
                                : BoxDecoration(color: accentLavender, shape: BoxShape.circle),
                              todayTextStyle: TextStyle(
                                color: isHighContrast ? Colors.yellow : minimalBlack,
                                fontWeight: FontWeight.bold
                              ),

                              selectedDecoration: BoxDecoration(
                                color: isHighContrast ? Colors.yellow : minimalBlack, 
                                shape: BoxShape.circle
                              ),
                              selectedTextStyle: TextStyle(
                                color: isHighContrast ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold
                              ),
                              
                              markerDecoration: BoxDecoration(
                                color: isHighContrast ? Colors.yellow : accentIndigo, 
                                shape: BoxShape.circle
                              ),
                            ),
                            headerStyle: HeaderStyle(
                              formatButtonVisible: false, 
                              titleCentered: true,
                              // NAZWA MIESIĄCA POGRUBIONA
                              titleTextStyle: TextStyle(
                                color: textColor, 
                                fontSize: 17, 
                                fontWeight: FontWeight.bold 
                              ),
                              leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
                              rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
                            ),
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
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: subTextColor),
                              ),
                              GestureDetector(
                                onTap: _showAddEventDialog,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isHighContrast ? Colors.yellow : minimalBlack, 
                                    shape: BoxShape.circle
                                  ),
                                  child: Icon(
                                    Icons.add, 
                                    color: isHighContrast ? Colors.black : Colors.white, 
                                    size: 20
                                  ),
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
                            
                            return GestureDetector(
                              onTap: () {
                                _showEditEventDialog(event, index);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: isHighContrast 
                                    ? Border.all(color: Colors.yellow) 
                                    : Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  // Wyrownanie do góry (ważne przy wielowierszowych tytułach)
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: isHighContrast ? Colors.black : accentLavender,
                                        borderRadius: BorderRadius.circular(12),
                                        border: isHighContrast ? Border.all(color: Colors.yellow) : null,
                                      ),
                                      child: Icon(
                                        isRecurrent ? Icons.repeat : Icons.access_time_filled, 
                                        color: isHighContrast ? Colors.yellow : accentIndigo,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Rząd: Tytuł + Etykieta w prawym górnym
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  event.title, 
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold, 
                                                    fontSize: 16,
                                                    color: textColor
                                                  )
                                                ),
                                              ),
                                              if (isRecurrent) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: isHighContrast ? Colors.black : tagBgColor,
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: isHighContrast ? Border.all(color: Colors.yellow) : null,
                                                  ),
                                                  child: Text(
                                                    _getRecurrenceLabel(event.recurrence),
                                                    style: TextStyle(
                                                      fontSize: 10, 
                                                      color: isHighContrast ? Colors.yellow : minimalBlack,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                )
                                              ]
                                            ],
                                          ),
                                          const SizedBox(height: 4), // Odstęp między tytułem a godziną
                                          Text(
                                            _formatTime24(event.time), 
                                            style: TextStyle(color: subTextColor)
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
    );
  }

  void _showAddEventDialog() {
    String newTitle = "";
    TimeOfDay newTime = TimeOfDay.now();
    RecurrenceType selectedRecurrence = RecurrenceType.none;
    
    final bool isHighContrast = ThemeService().isHighContrast.value;
    
    // KOLORY DIALOGU
    final Color minimalBlack = const Color(0xFF1E1E1E); 
    final Color accentIndigo = const Color(0xFF5757DB);

    final Color primaryActionColor = isHighContrast ? Colors.yellow : minimalBlack;
    final Color textColor = isHighContrast ? Colors.yellow : const Color(0xFF2D2D2D);
    final Color bgColor = isHighContrast ? Colors.black : Colors.white;
    final Color subTextColor = isHighContrast ? Colors.yellow : Colors.grey;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: bgColor,
              surfaceTintColor: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: isHighContrast ? BorderSide(color: Colors.yellow) : BorderSide.none,
              ),
              title: Text("Nowe przypomnienie", style: TextStyle(color: textColor)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: "Co masz do zrobienia?",
                      labelStyle: TextStyle(color: subTextColor),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryActionColor, width: 2)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: subTextColor)),
                      border: const OutlineInputBorder(),
                    ),
                    cursorColor: primaryActionColor,
                    onChanged: (val) => newTitle = val,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Godzina: ${_formatTime24(newTime)}", style: TextStyle(fontSize: 16, color: textColor)),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: accentIndigo),
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: newTime,
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: isHighContrast 
                                  ? ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Colors.yellow,
                                        onPrimary: Colors.black,
                                        surface: Colors.black,
                                        onSurface: Colors.yellow,
                                      ),
                                    )
                                  : ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: minimalBlack,
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: Colors.black,
                                      ),
                                      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: minimalBlack)),
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
                  Text("Powtarzanie:", style: TextStyle(color: subTextColor, fontSize: 12)),
                  DropdownButtonFormField<RecurrenceType>(
                    value: selectedRecurrence,
                    dropdownColor: bgColor,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: subTextColor)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryActionColor),
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
                  style: TextButton.styleFrom(foregroundColor: subTextColor),
                  child: const Text("Anuluj"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryActionColor,
                    foregroundColor: isHighContrast ? Colors.black : Colors.white,
                  ),
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
                  child: const Text("Dodaj"),
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

    final bool isHighContrast = ThemeService().isHighContrast.value;
    
    // KOLORY DIALOGU
    final Color minimalBlack = const Color(0xFF1E1E1E); 
    final Color accentIndigo = const Color(0xFF5757DB);

    final Color primaryActionColor = isHighContrast ? Colors.yellow : minimalBlack;
    final Color textColor = isHighContrast ? Colors.yellow : const Color(0xFF2D2D2D);
    final Color bgColor = isHighContrast ? Colors.black : Colors.white;
    final Color subTextColor = isHighContrast ? Colors.yellow : Colors.grey;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: bgColor,
              surfaceTintColor: bgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: isHighContrast ? BorderSide(color: Colors.yellow) : BorderSide.none,
              ),
              title: Text("Edytuj przypomnienie", style: TextStyle(color: textColor)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: TextEditingController(text: newTitle),
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      labelText: "Co masz do zrobienia?",
                      labelStyle: TextStyle(color: subTextColor),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: primaryActionColor, width: 2)),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: subTextColor)),
                      border: const OutlineInputBorder(),
                    ),
                    cursorColor: primaryActionColor,
                    onChanged: (val) => newTitle = val,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Godzina: ${_formatTime24(newTime)}", style: TextStyle(fontSize: 16, color: textColor)),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: accentIndigo),
                        onPressed: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: newTime,
                            builder: (BuildContext context, Widget? child) {
                              return Theme(
                                data: isHighContrast 
                                  ? ThemeData.dark().copyWith(
                                      colorScheme: const ColorScheme.dark(
                                        primary: Colors.yellow,
                                        onPrimary: Colors.black,
                                        surface: Colors.black,
                                        onSurface: Colors.yellow,
                                      ),
                                    )
                                  : ThemeData.light().copyWith(
                                      colorScheme: ColorScheme.light(
                                        primary: minimalBlack,
                                        onPrimary: Colors.white,
                                        surface: Colors.white,
                                        onSurface: Colors.black
                                      ),
                                      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: minimalBlack)),
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryActionColor,
                    foregroundColor: isHighContrast ? Colors.black : Colors.white,
                  ),
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
                    }
                  },
                  child: const Text("Zapisz"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}