import 'dart:async';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart'; // Add this package
import '../Models/waterLogModel.dart';
import '../Services/waterLogdbHelper.dart';

class WaterTrackerView extends StatefulWidget {
  @override
  _WaterTrackerViewState createState() => _WaterTrackerViewState();
}

class _WaterTrackerViewState extends State<WaterTrackerView> {
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
      totalIntake = logs.fold(0, (sum, log) => sum + log.amount);
    });
  }

  void _scheduleMidnightRefresh() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);

    _midnightTimer?.cancel();
    _midnightTimer = Timer(durationUntilMidnight, () {
      _refresh();
      _scheduleMidnightRefresh();
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
    _midnightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (totalIntake / goal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Color(0xFFF4F9FF),
      appBar: AppBar(
        centerTitle: true,
        title: Text("Water Tracker", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Today's Water Intake",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30),
          CircularPercentIndicator(
            radius: 150.0,
            lineWidth: 15.0,
            animation: true,
            percent: progress,
            center: Text(
              "$totalIntake ml\nof $goal ml",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.blueAccent,
            backgroundColor: Colors.blue.shade100,
          ),
          SizedBox(height: 40),
          Text("Add Water", style: TextStyle(fontSize: 20)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                [250, 500, 750].map((amount) {
                  return GlassButton(
                    label: "+$amount ml",
                    onTap: () {
                      if (totalIntake + amount <= goal) _addWater(amount);
                    },
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

// Custom Glassmorphism Button
class GlassButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const GlassButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.2),
          border: Border.all(color: Colors.white70),
          boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ),
      ),
    );
  }
}
