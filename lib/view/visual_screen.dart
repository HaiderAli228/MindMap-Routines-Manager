import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class VisualScreen extends StatefulWidget {
  final Function(DateTime selectedDate) onDateSelected;
  final List<Map<String, dynamic>> notesList; // Receive the notes list

  const VisualScreen({
    Key? key,
    required this.onDateSelected,
    required this.notesList,
  }) : super(key: key);

  @override
  _VisualScreenState createState() => _VisualScreenState();
}

class _VisualScreenState extends State<VisualScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  // Safely handle null values and invalid dates
  List<Map<String, dynamic>> _getNotesForSelectedDate() {
    return widget.notesList.where((note) {
      final createdAt = note['createdAt'];
      if (createdAt != null) {
        final createdDate = DateTime.tryParse(createdAt);
        if (createdDate != null) {
          return createdDate.year == _selectedDay.year &&
              createdDate.month == _selectedDay.month &&
              createdDate.day == _selectedDay.day;
        }
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final notesForSelectedDate = _getNotesForSelectedDate();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calendar View"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 10, 16),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                widget.onDateSelected(selectedDay); // Pass the selected date
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
          ),
          Expanded(
            child: notesForSelectedDate.isNotEmpty
                ? ListView.builder(
              itemCount: notesForSelectedDate.length,
              itemBuilder: (context, index) {
                final note = notesForSelectedDate[index];
                return ListTile(
                  title: Text(note['title']),
                  subtitle: Text(note['description']),
                );
              },
            )
                : const Center(
              child: Text("No notes for this day."),
            ),
          ),
        ],
      ),
    );
  }
}
