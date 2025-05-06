import 'dart:async';
import 'package:flutter/material.dart';
import '../Models/waterLogModel.dart';
import '../Services/waterLogdbHelper.dart';

class WaterTrackerScreen extends StatefulWidget {
  @override
  _WaterTrackerScreenState createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  int totalIntake = 0;
  final goal = 2500;
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    _refresh();
    _scheduleMidnightRefresh();
  }

  Future _refresh() async {
    final logs = await WaterDatabase.instance.getTodayLogs();
    setState(() {
      if (totalIntake < 2500) {
        totalIntake = logs.fold(0, (sum, log) => sum + log.amount);
      }
    });
  }

  void _scheduleMidnightRefresh() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);

    _midnightTimer?.cancel(); // Cancel previous timer if any
    _midnightTimer = Timer(durationUntilMidnight, () {
      _refresh(); // Update UI at midnight
      _scheduleMidnightRefresh(); // Schedule next refresh
    });
  }

  void _addWater(int amount) async {
    await WaterDatabase.instance.create(
      WaterLog(amount: amount, date: DateTime.now()),
    );
    _refresh();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel(); // Clean up timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = totalIntake / goal;

    return Scaffold(
      appBar: AppBar(title: Text("Water Tracker")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Today’s Water Intake", style: TextStyle(fontSize: 22)),
            SizedBox(height: 20),
            LinearProgressIndicator(
              value: progress > 1.0 ? 1.0 : progress,
              minHeight: 20,
              backgroundColor: Colors.grey[300],
              color: Colors.blueAccent,
            ),
            SizedBox(height: 20),
            Text("$totalIntake ml / $goal ml", style: TextStyle(fontSize: 18)),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children:
                  [250, 500, 750].map((amount) {
                    return ElevatedButton(
                      onPressed: () {
                        if (goal >= totalIntake + amount) {
                          _addWater(amount);
                        }
                      },
                      child: Text("+$amount ml"),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
