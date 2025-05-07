import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Models/eventModel.dart';
import '../Services/calenderdbHelper.dart';

class CalenderView extends StatefulWidget {
  @override
  _CalenderViewState createState() => _CalenderViewState();
}

class _CalenderViewState extends State<CalenderView> {
  DateTime selectedDate = DateTime.now();
  List<Event> _events = [];
  bool isMonthView = false;

  List<Map<String, String>> weatherInfo = [
    {"label": "Weather", "icon": "☀️"},
    {"label": "65% Rain", "icon": "🌧️"},
    {"label": "8 km/h Wind", "icon": "🌬️"},
    {"label": "25% Strom", "icon": "⛈️"},
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await EventDatabase.instance.readByDate(selectedDate);
    setState(() => _events = events);
  }

  void selectDay(DateTime day) {
    setState(() {
      selectedDate = day;
    });
    _loadEvents();
  }

  void _addOrEditEventBottomSheet({Event? event}) {
    final controller = TextEditingController(text: event?.title ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 60,
              left: 20,
              right: 20,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event == null ? 'Add Event' : 'Edit Event',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Event Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final text = controller.text.trim();
                      if (text.isEmpty) return;

                      if (event == null) {
                        await EventDatabase.instance.create(
                          Event(title: text, date: selectedDate),
                        );
                      } else {
                        await EventDatabase.instance.update(
                          event.copyWith(title: text),
                        );
                      }

                      Navigator.of(context).pop();
                      _loadEvents();
                    },
                    icon: Icon(Icons.save, color: Colors.white),
                    label: Text('Save', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _toggleView() {
    setState(() {
      isMonthView = !isMonthView;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime startOfWeek = selectedDate.subtract(
      Duration(days: selectedDate.weekday % 7),
    );
    List<DateTime> weekDays = List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );

    DateTime startOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    int daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;
    List<DateTime> monthDays = List.generate(
      daysInMonth,
      (index) => startOfMonth.add(Duration(days: index)),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(
              isMonthView ? Icons.view_week : Icons.calendar_month,
              color: Colors.white,
            ),
            onPressed: _toggleView,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            buildHeader(),
            const SizedBox(height: 16),
            isMonthView
                ? buildMonthView(monthDays)
                : buildWeekDaysRow(weekDays),
            const SizedBox(height: 16),
            buildWeatherRow(),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Events',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: buildEventsList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => _addOrEditEventBottomSheet(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              selectedDate =
                  isMonthView
                      ? DateTime(
                        selectedDate.year,
                        selectedDate.month - 1,
                        selectedDate.day,
                      )
                      : selectedDate.subtract(Duration(days: 7));
            });
            _loadEvents();
          },
        ),
        Text(
          isMonthView
              ? "${_monthName(selectedDate.month)} ${selectedDate.year}"
              : "${_weekdayName(selectedDate.weekday)}, ${_monthName(selectedDate.month)} ${selectedDate.day}, ${selectedDate.year}",
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        IconButton(
          icon: Icon(Icons.arrow_forward),
          onPressed: () {
            setState(() {
              selectedDate =
                  isMonthView
                      ? DateTime(
                        selectedDate.year,
                        selectedDate.month + 1,
                        selectedDate.day,
                      )
                      : selectedDate.add(Duration(days: 7));
            });
            _loadEvents();
          },
        ),
      ],
    );
  }

  Widget buildWeekDaysRow(List<DateTime> weekDays) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children:
          weekDays.map((day) {
            bool isSelected = isSameDay(day, selectedDate);
            return GestureDetector(
              onTap: () => selectDay(day),
              child: Column(
                children: [
                  Text(
                    _shortWeekdayName(day.weekday),
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${day.day}',
                      style: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget buildMonthView(List<DateTime> monthDays) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 7,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      children:
          monthDays.map((day) {
            bool isSelected = isSameDay(day, selectedDate);
            return GestureDetector(
              onTap: () => selectDay(day),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget buildWeatherRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            weatherInfo.map((item) {
              return Column(
                children: [
                  Text(item["icon"]!, style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(
                    item["label"]!,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  Widget buildEventsList() {
    if (_events.isEmpty) {
      return Center(
        child: Text(
          'No events',
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      );
    }

    return ListView.separated(
      itemCount: _events.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final event = _events[index];
        return GestureDetector(
          onLongPress: () => _addOrEditEventBottomSheet(event: event),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                event.title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red.shade300),
                onPressed: () async {
                  await EventDatabase.instance.delete(event.id!);
                  _loadEvents();
                },
              ),
            ),
          ),
        );
      },
    );
  }

  bool isSameDay(DateTime day1, DateTime day2) {
    return day1.year == day2.year &&
        day1.month == day2.month &&
        day1.day == day2.day;
  }

  String _monthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  String _weekdayName(int weekday) {
    const weekdays = [
      "Sunday",
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
    ];
    return weekdays[weekday - 1];
  }

  String _shortWeekdayName(int weekday) {
    const weekdays = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"];
    return weekdays[weekday - 1];
  }
}

// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
//
// import '../Models/eventModel.dart';
// import '../Services/calenderdbHelper.dart';
//
// class CalendarScreen extends StatefulWidget {
//   @override
//   _CalendarScreenState createState() => _CalendarScreenState();
// }
//
// class _CalendarScreenState extends State<CalendarScreen> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime _selectedDay = DateTime.now();
//   List<Event> _events = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadEvents();
//   }
//
//   Future<void> _loadEvents() async {
//     final events = await EventDatabase.instance.readByDate(_selectedDay);
//     setState(() => _events = events);
//   }
//
//   void _addEventDialog() {
//     final controller = TextEditingController();
//     showDialog(
//       context: context,
//       builder:
//           (_) => AlertDialog(
//             title: Text('Add Event'),
//             content: TextField(
//               controller: controller,
//               decoration: InputDecoration(labelText: 'Event Title'),
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () async {
//                   if (controller.text.trim().isEmpty) return;
//                   await EventDatabase.instance.create(
//                     Event(title: controller.text.trim(), date: _selectedDay),
//                   );
//                   Navigator.pop(context);
//                   _loadEvents();
//                 },
//                 child: Text('Save'),
//               ),
//             ],
//           ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return  FloatingActionButton(
//       onPressed: _addEventDialog,
//       child: Icon(Icons.add),
//     );
//     //   Scaffold(
//     //   appBar: AppBar(title: Text('Calendar Events')),
//     //   body: Column(
//     //     children: [
//     //       TableCalendar(
//     //         focusedDay: _focusedDay,
//     //         firstDay: DateTime.utc(2000),
//     //         lastDay: DateTime.utc(2100),
//     //         selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
//     //         onDaySelected: (selected, focused) {
//     //           setState(() {
//     //             _selectedDay = selected;
//     //             _focusedDay = focused;
//     //           });
//     //           _loadEvents();
//     //         },
//     //       ),
//     //       Expanded(
//     //         child: ListView.builder(
//     //           itemCount: _events.length,
//     //           itemBuilder: (_, index) {
//     //             final event = _events[index];
//     //             return ListTile(
//     //               title: Text(event.title),
//     //               trailing: IconButton(
//     //                 icon: Icon(Icons.delete, color: Colors.red),
//     //                 onPressed: () async {
//     //                   await EventDatabase.instance.delete(event.id!);
//     //                   _loadEvents();
//     //                 },
//     //               ),
//     //             );
//     //           },
//     //         ),
//     //       ),
//     //     ],
//     //   ),
//     //   floatingActionButton: FloatingActionButton(
//     //     onPressed: _addEventDialog,
//     //     child: Icon(Icons.add),
//     //   ),
//     // );
//   }
// }
