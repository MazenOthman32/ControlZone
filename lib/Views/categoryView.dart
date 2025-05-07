import 'package:flutter/material.dart';
import 'package:untitled/Views/notesView.dart';
import 'package:untitled/Views/tasksView.dart';
import 'package:untitled/Views/toDoView.dart';

class CategorySelectionView extends StatelessWidget {
  final List<Map<String, String>> categories = [
    {'name': 'Work', 'image': 'assets/work.png'},
    {'name': 'Personal', 'image': 'assets/personal.png'},
    {'name': 'Shopping', 'image': 'assets/shopping.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Category')),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => TasksByCategoryView(category: category['name']!),
                ),
              );
            },
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(category['image']!, width: 60, height: 60),
                  SizedBox(height: 10),
                  Text(category['name']!, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: TodoView(),
    );
  }
}
