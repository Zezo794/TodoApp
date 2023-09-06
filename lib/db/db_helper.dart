import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';

import '../models/task.dart';

class DBHelper {
  static Database? db;
  static final int version =1;
  static final String tableName ='tasks';

  static Future<void> initDb() async{
    if(db!= null){
      debugPrint('not null db');
      return;
    }
    else{
      try{
        var path = await getDatabasesPath()+'task.db';
        debugPrint('in database path');
        db=await openDatabase(path,version: version,
            onCreate: (Database db, int version) async {
              debugPrint('create anew one');
              await db.execute(
                  'CREATE TABLE $tableName (id INTEGER PRIMARY KEY AUTOINCREMENT, title STRING, note TEXT, date STRING ,  startTime String , endTime String , remind INTEGER , repeat String ,  color INTEGER  , isCompleted INTEGER )');
            });
      }catch(e){
         print(e);
      }
    }
  }


  static Future<int?> insert(Task  task) async{
    print('insert');
    try{
      return await db!.insert(tableName, task.toJson());
    }catch(e){
      print(e);
    }

  }


  static Future<int> delete(Task task) async{
    print('delete');
    return await db!.delete(tableName, where: 'id = ?', whereArgs: [task.id]);
  }


  static Future<int> deleteALL() async{
    print('delete');
    return await db!.delete(tableName);
  }


  static Future<List<Map<String, dynamic>>> query() async{
    print('query');
    try{
      return await db!.query(tableName);
    }catch(e){
      print('notQuery');
      print(e);
    }
    return [];

  }


  static Future<int> update(int id) async{
    print('update');
    return await db!.rawUpdate('''
      UPDATE tasks 
      SET isCompleted = ?
      WHERE id = ?
    ''',[1,id]);
  }

}
