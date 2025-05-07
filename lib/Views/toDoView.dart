import 'package:flutter/material.dart';

import '../Models/toDoModel.dart';
import '../Services/toDoDbHelper.dart';

class TodoView extends StatefulWidget {
  @override
  _TodoViewState createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  List<Todo> todos = [];

  @override
  void initState() {
    super.initState();
    refreshTodos();
  }

  Future refreshTodos() async {
    todos = await TodoDatabase.instance.readAll();
    setState(() {});
  }

  void _showTaskDialog({Todo? todo}) {
    final controller = TextEditingController(text: todo?.task);
    String selectedCategory = todo?.category ?? 'General';

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(todo == null ? 'New Task' : 'Edit Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(labelText: 'Task'),
                ),
                SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  items:
                      ['General', 'Work', 'Study', 'Personal', 'Shopping'].map((
                        cat,
                      ) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) selectedCategory = value;
                  },
                  decoration: InputDecoration(labelText: 'Category'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;

                  if (todo == null) {
                    await TodoDatabase.instance.create(
                      Todo(task: text, category: selectedCategory),
                    );
                  } else {
                    await TodoDatabase.instance.update(
                      todo.copyWith(task: text, category: selectedCategory),
                    );
                  }

                  Navigator.pop(context);
                  refreshTodos();
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  void _toggleDone(Todo todo) async {
    await TodoDatabase.instance.update(todo.copyWith(isDone: !todo.isDone));
    refreshTodos();
  }

  void _deleteTask(int id) async {
    await TodoDatabase.instance.delete(id);
    refreshTodos();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Work':
        return Colors.blue.shade100;
      case 'Study':
        return Colors.orange.shade100;
      case 'Personal':
        return Colors.green.shade100;
      case 'Shopping':
        return Colors.purple.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showTaskDialog(),
      child: Icon(Icons.add),
    );
    //   Scaffold(
    //   body: ListView.builder(
    //     itemCount: todos.length,
    //     itemBuilder: (_, index) {
    //       final todo = todos[index];
    //       return Card(
    //         color: _getCategoryColor(todo.category),
    //         child: ListTile(
    //           title: Text(
    //             todo.task,
    //             style: TextStyle(
    //               decoration: todo.isDone ? TextDecoration.lineThrough : null,
    //             ),
    //           ),
    //           subtitle: Text(todo.category),
    //           leading: Checkbox(
    //             value: todo.isDone,
    //             onChanged: (_) => _toggleDone(todo),
    //           ),
    //           trailing: IconButton(
    //             icon: Icon(Icons.delete, color: Colors.red),
    //             onPressed: () => _deleteTask(todo.id!),
    //           ),
    //           onTap: () => _showTaskDialog(todo: todo),
    //         ),
    //       );
    //     },
    //   ),
    //   floatingActionButton: FloatingActionButton(
    //     onPressed: () => _showTaskDialog(),
    //     child: Icon(Icons.add),
    //   ),
    // );
  }
}
