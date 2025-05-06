import 'package:flutter/material.dart';
import 'package:untitled/Views/notesView.dart';
import 'package:untitled/Views/toDoView.dart';
import 'package:untitled/Views/waterLogView.dart';

import 'calenderView.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    TodoView(),
    NotesView(),
    CalendarScreen(),
    WaterTrackerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Icon()),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'To-Do',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Notes'),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.water_drop), label: 'Water'),
        ],
      ),
    );
  }
}
