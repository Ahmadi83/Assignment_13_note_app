
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:note_app_2/Database.dart';
import 'package:note_app_2/Note_screen.dart';

class MyApp1 extends StatefulWidget {
  final Note? note;

  const MyApp1({super.key, this.note});

  @override
  State<MyApp1> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp1> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _noteController = TextEditingController();

  List<Note> _notes = [];

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _noteController.text = widget.note!.description;
    }
    _fetchNotes(); // فراخوانی نوت‌ها از دیتابیس
  }

  Future<void> _fetchNotes() async {
    List<Note>? notes = await DatabaseHelper.getAllNotes();
    setState(() {
      _notes = notes!;
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final title = _titleController.value.text;
          final description = _noteController.value.text;

          if (title.isEmpty || description.isEmpty) {
            return;
          }
          final Note model =
              Note(title: title, description: description, id: widget.note?.id);

          if (widget.note == null) {
            await DatabaseHelper.addNote(model);
          } else {
            await DatabaseHelper.updateNote(model);
          }
          _fetchNotes();

          setState(() {
            _titleController.clear();
            _noteController.clear();
          });
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(widget.note == null ? 'Add Note' : "Edit Note"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Enter your note Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter your Note',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 20),
          const  Divider(
              height: 2,
              indent: 2,
              endIndent: 2,
              color: Colors.blueAccent,
              thickness: 2,
            ),
            Expanded(
              child: ListView.separated(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  var note = _notes[index];
                  
                  return ListTile(
                    title: Text(note.title,style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(note.description,),
                   //leading: Icon(Icons.note),
                  
                    trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          print('Deleting Note id is ${note.id}');
                          await DatabaseHelper.deleteNote(note.id!);
                          _fetchNotes(); // به‌روزرسانی لیست پس از حذف
                        }),
                  
                     onLongPress: () async {
                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) {
                          return MyApp1(note: note,);
                          },
                      ));
                      _fetchNotes();
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    height: 30,
                    color: Colors.red,
                    thickness: 1,
                    indent: 15,
                    endIndent: 15,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
