import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 60,
              left: 20,
              right: 20,
              top: 24,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    note == null ? 'New Diary' : 'Edit Note',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  TextField(
                    controller: contentController,
                    minLines: 3,
                    maxLines: 5,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      final content = contentController.text.trim();
                      if (title.isEmpty || content.isEmpty) return;

                      if (note == null) {
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
                    icon: Icon(Icons.save, color: Colors.white),
                    label: Text('Save', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
      backgroundColor: Color(0xFFF9F8FD),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'My Diary',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return GestureDetector(
              onTap: () => _showForm(note: note),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(2, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      note.content,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red.shade300),
                        onPressed: () => _deleteNote(note.id!),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(),
        backgroundColor: Colors.teal,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
