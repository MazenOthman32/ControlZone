import 'package:Control_Zone/Views/tasksView.dart';
import 'package:Control_Zone/Views/toDoView.dart';
import 'package:flutter/material.dart';

class CategorySelectionView extends StatelessWidget {
  final List<Goal> goals = [
    Goal("Work", "assets/images/Work.jpg", Colors.orange[100]!),
    Goal("Build a skill", "assets/images/BuildSkill.jpg", Colors.blue[100]!),
    Goal("Family Time", "assets/images/Family.jpg", Colors.purple[100]!),
    Goal("Study Time", "assets/images/Study.jpg", Colors.teal[100]!),
    Goal("Sport", "assets/images/Sports.jpg", Colors.blue[100]!),
    Goal("Hobie", "assets/images/Hobie.jpg", Colors.indigo[100]!),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: goals.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final goal = goals[index];
            final isLarge = index == 0; // make first card large
            return GridTile(
              child: GoalCard(
                goal: goal,
                isLarge: isLarge,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TasksByCategoryView(category: goal.title),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: TodoView(),
    );
  }
}

class GoalCard extends StatelessWidget {
  final Goal goal;
  final bool isLarge;
  final VoidCallback onTap;

  const GoalCard({
    required this.goal,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isLarge ? 200 : null,
      decoration: BoxDecoration(
        color: goal.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: isLarge ? 2 : 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(goal.imagePath, fit: BoxFit.contain),
              ),
            ),
            SizedBox(height: 8),
            Text(
              goal.title,
              style: TextStyle(
                fontSize: isLarge ? 18 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class Goal {
  final String title;
  final String imagePath;
  final Color backgroundColor;

  Goal(this.title, this.imagePath, this.backgroundColor);
}
