import 'package:note_app_2/Note_screen.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper{

 static const int _version =1;
 static const String _dbName ='Notes.db';

  static  Future<Database> _getdb() async{

     return openDatabase(join( await getDatabasesPath(),_dbName),
    onCreate: (db,version) async=>
        await db.execute("Create table note(id integer Primary key AUTOINCREMENT ,title text not null,description Text not null)"),
        version: _version
    );
  }


  static Future<int> addNote(Note note)async{

    final db = await _getdb();
    return await db.insert("note",note.toJson(),
        conflictAlgorithm:ConflictAlgorithm.replace);
  }


  static Future<int> updateNote(Note note)async{
    final db = await _getdb();
    return await db.update('note', note.toJson(),where: 'id = ?',whereArgs: [note.id],
    conflictAlgorithm: ConflictAlgorithm.replace
    );
  }


  static Future<int> deleteNote(int id )async{
    final db = await _getdb();
    return await db.delete('note',where: 'id  = ?',whereArgs: [id]);
  }



  static Future<List<Note>?> getAllNotes()async{
    final db = await _getdb();

    final List<Map<String,dynamic>> maps = await db.query('note');

    if(maps.isEmpty){
      return null;
    }

    return List.generate(maps.length, (index) => Note.fromJson(maps[index]),);

  }


}