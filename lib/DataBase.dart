import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'FavoriteModel.dart';

class DBProvide{
  DBProvide._();
  static final DBProvide db = DBProvide._();

  static Database _database;

  Future <Database> get database async{
    if(_database != null){
      return _database;
    }
    _database = await initDB();
    return _database;
  }

  initDB() async{
    Directory documentdirectory = await getApplicationDocumentsDirectory();
    String path = join(documentdirectory.path,'test99.db');
    return await openDatabase(path, version: 1, onOpen: (db){} ,onCreate: (Database db, int version)async{
      await db.execute("CREATE TABLE FavoriteTime ("
        "time INTEGER PRIMARY KEY NOT NULL,"
        "title TEXT,"
        "isFavorite BIT)"
      );
    } );

  }

  newFavoriteTimer(FavoriteTime newFavoriteTimer) async{
    final db = await database;
   
    var res = await db.rawInsert(
      "INSERT Into FavoriteTime (title,time,isFavorite)"
      "VALUES(?,?,?)",
      [newFavoriteTimer.title,newFavoriteTimer.time,newFavoriteTimer.isFavorite]
    );
    return res;
  }


  Future <FavoriteTime> getFavoritTimeByTime(int time)async{
    final db = await database;
    var res = await db.query("FavoriteTime", where: "time = ?",whereArgs: [time]);
    FavoriteTime x= res.isNotEmpty? FavoriteTime.fromJson(res.first):null;
    return x;
  }

  Future<List<FavoriteTime>> getAllFavoriteTime() async{
    final db = await database;
    var res = await  db.query("FavoriteTime",columns: ["time","title","isFavorite"]);
    List<FavoriteTime> list = 
    res.isNotEmpty? List<FavoriteTime>.from(res.map((c)=>FavoriteTime.fromJson(c))):[];
    return list;
  }

  Future<List<FavoriteTime>> getOnlyFavoritesTrue() async{
    final db = await  database;
    var res = await db.rawQuery("SELECT * FROM FavoriteTime  where isFavorite = 1");
    List<FavoriteTime> list = 
    res.isNotEmpty? List<FavoriteTime>.from(res.map((i)=>FavoriteTime.fromJson(i))):null;
    return list;
  }


  updateTime(FavoriteTime newFavoriteTime) async{
    final db = await database;
    var res = await  db.update("FavoriteTime", newFavoriteTime.toJson(), where: "time= ? ", whereArgs: [newFavoriteTime.time]);
    return res;
  }


  favoriteOrUnfavorite(FavoriteTime favorite)async{
    final db = await database;
    FavoriteTime yes   = FavoriteTime(
      time: favorite.time,
      title: favorite.title,
      isFavorite: favorite.isFavorite 
    );
    var res = await db.update("FavoriteTime", yes.toJson(),where: "time = ?",whereArgs: [favorite.time]);
    return res; 
  }


  deleteTime(int time) async{
    final db = await database;
    db.delete("FavoriteTime", where: "time = ?", whereArgs: [time]);
  }

  deleteAll()async{
    final db = await database;
    db.rawDelete("Delete * from FavoriteTime");
  }
}