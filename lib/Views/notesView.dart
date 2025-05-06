import 'package:flutter/material.dart';

import '../Models/noteModels.dart';
import '../Services/dbHelper.dart';

class NotesView extends StatefulWidget {
  @override
  _NotesViewState createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  Future refreshNotes() async {
    notes = await NotesDatabase.instance.readAllNotes();
    setState(() {});
  }

  void _showForm({Note? note}) {
    final titleController = TextEditingController(text: note?.title);
    final contentController = TextEditingController(text: note?.content);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(note == null ? 'New Diary' : 'Edit Note'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: contentController,
                  decoration: InputDecoration(labelText: 'Content'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final title = titleController.text.trim();
                  final content = contentController.text.trim();

                  if (title.isEmpty || content.isEmpty) return;

                  if (note == null) {
                    // CREATE
                    await NotesDatabase.instance.create(
                      Note(title: title, content: content),
                    );
                  } else {
                    await NotesDatabase.instance.update(
                      note.copyWith(title: title, content: content),
                    );
                  }

                  Navigator.of(context).pop();
                  refreshNotes();
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  void _deleteNote(int id) async {
    await NotesDatabase.instance.delete(id);
    refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Diary')),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note.title),
            subtitle: Text(note.content),
            onTap: () => _showForm(note: note),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteNote(note.id!),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
