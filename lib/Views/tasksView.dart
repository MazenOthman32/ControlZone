import 'package:flutter/material.dart';

import '../Models/toDoModel.dart';
import '../Services/toDoDbHelper.dart';

class TasksByCategoryView extends StatefulWidget {
  final String category;
  const TasksByCategoryView({required this.category});

  @override
  State<TasksByCategoryView> createState() => _TasksByCategoryViewState();
}

class _TasksByCategoryViewState extends State<TasksByCategoryView> {
  List<Todo> todos = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final allTasks = await TodoDatabase.instance.readAll();
    todos = allTasks.where((t) => t.category == widget.category).toList();
    setState(() {});
  }

  void _toggleDone(Todo todo) async {
    await TodoDatabase.instance.update(todo.copyWith(isDone: !todo.isDone));
    _loadTasks();
  }

  void _deleteTask(int id) async {
    await TodoDatabase.instance.delete(id);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.teal,
        title: Text(
          '${widget.category} Tasks',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (_, index) {
          final todo = todos[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: ListTile(
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                todo.task,
                style: TextStyle(
                  decoration: todo.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              leading: Checkbox(
                value: todo.isDone,
                onChanged: (_) => _toggleDone(todo),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red.shade300),
                onPressed: () => _deleteTask(todo.id!),
              ),
            ),
          );
        },
      ),
    );
  }
}
