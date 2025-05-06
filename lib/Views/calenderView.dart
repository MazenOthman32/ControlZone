import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../Models/eventModel.dart';
import '../Services/calenderdbHelper.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await EventDatabase.instance.readByDate(_selectedDay);
    setState(() => _events = events);
  }

  void _addEventDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Add Event'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(labelText: 'Event Title'),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;
                  await EventDatabase.instance.create(
                    Event(title: controller.text.trim(), date: _selectedDay),
                  );
                  Navigator.pop(context);
                  _loadEvents();
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendar Events')),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2000),
            lastDay: DateTime.utc(2100),
            selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
              _loadEvents();
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (_, index) {
                final event = _events[index];
                return ListTile(
                  title: Text(event.title),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await EventDatabase.instance.delete(event.id!);
                      _loadEvents();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEventDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
