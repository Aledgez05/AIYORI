import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/theme/app_colors.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  /// Mock de datos (luego lo conectamos a Firebase!!!!!!!!!!!!!!)
  final Map<DateTime, String> moodData = {
    DateTime.utc(2026, 4, 5): 'Bien',
    DateTime.utc(2026, 4, 6): 'Mal',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario emocional'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(selectedDay, day);
              },
              onDaySelected: (selected, focused) {
                setState(() {
                  selectedDay = selected;
                  focusedDay = focused;
                });
              },

              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.accentSoft,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (selectedDay != null)
              _moodInfo(selectedDay!)
          ],
        ),
      ),
    );
  }

  Widget _moodInfo(DateTime day) {
    final mood = moodData[DateTime.utc(day.year, day.month, day.day)];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        mood != null
            ? 'Estado ese día: $mood'
            : 'No hay registro para este día',
      ),
    );
  }
}