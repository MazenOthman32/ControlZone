import 'package:flutter/material.dart';
import 'package:untitled/Views/notesView.dart';
import 'package:untitled/Views/toDoView.dart';
import 'package:untitled/Views/waterLogView.dart';

import 'calenderView.dart';
import 'categoryView.dart';
import 'focusView.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  bool _isFocusLocked = false;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      CategorySelectionView(),
      NotesView(),
      CalendarScreen(),
      WaterTrackerScreen(),
      FocusView(
        onLockChange: (locked) {
          setState(() {
            _isFocusLocked = locked;
          });
        },
      ),
    ]);
  }

  void _onTabTapped(int index) {
    if (_isFocusLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Can't switch tabs during focus mode.")),
      );
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'To-Do',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Diary'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.water_drop), label: 'Water'),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_center_focus),
            label: 'Focus',
          ),
        ],
      ),
    );
  }
}
