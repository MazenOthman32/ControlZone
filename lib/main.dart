import 'package:flutter/material.dart';

import 'Views/calenderView.dart';
import 'Views/homeView.dart';
import 'Views/notesView.dart';
import 'Views/toDoView.dart';
import 'Views/waterLogView.dart';

void main() async {
  runApp(NoteApp());
}

class NoteApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => HomeView(),
        '/notes': (context) => NotesView(),
        '/todo': (context) => TodoView(),
        '/calendar': (context) => CalendarScreen(),
        '/water': (context) => WaterTrackerScreen(),
      },
    );
  }
}
