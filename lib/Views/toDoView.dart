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
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(todo == null ? 'New Task' : 'Edit Task'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(labelText: 'Task'),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final text = controller.text.trim();
                  if (text.isEmpty) return;

                  if (todo == null) {
                    await TodoDatabase.instance.create(Todo(task: text));
                  } else {
                    await TodoDatabase.instance.update(
                      todo.copyWith(task: text),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('To-Do List')),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (_, index) {
          final todo = todos[index];
          return ListTile(
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
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTask(todo.id!),
            ),
            onTap: () => _showTaskDialog(todo: todo),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
