import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show Uint8List;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = 'alemar_realty.db';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  static get databaseFactoryIo => null;

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = documentsDirectory.path + _databaseName;

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  void _onCreate(Database db, int version) {
    db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT,
        email TEXT,
        password TEXT,
        profilePicturePath TEXT,
        profilePicUrl TEXT
      )
    ''');

    db.execute('''
      CREATE TABLE posts (
        id INTEGER PRIMARY KEY,
        text TEXT,
        image TEXT,
        comments TEXT
      )
    ''');
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;

    await db.insert(
      'users',
      {
        'id': user['id'],
        'name': user['name'],
        'email': user['email'],
        'password': user['password'],
        'profilePicturePath': user['profilePicturePath'] ?? '',
        'profilePicUrl': user['profilePicUrl'] ?? '',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>> getUser(String email) async {
    final db = await instance.database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      return {};
    }
  }

  Future<void> insertPost(Map<String, dynamic> post) async {
    final db = await instance.database;
    final jsonString = json.encode(post['comments']);
    if (post['id'] != null) {
      await db.insert(
        'posts',
        {
          'id': post['id'] as int,
          'text': post['text'],
          'image': post['image'],
          'comments': jsonString,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      final id = await db.insert('posts', {
        'text': post['text'],
        'image': post['image'],
        'comments': jsonString,
      });
      post['id'] = id;
    }
  }

  Future<int> insertPostFromPostObject(post) async {
    final db = await instance.database;

    final jsonString = json.encode(post.toJson());
    final jsonBytes = utf8.encode(jsonString);

    return await db.insert(
      'posts',
      {
        'id': post.id,
        'title': post.title,
        'body': post.body,
        'comments': Uint8List.fromList(jsonBytes),
      },
    );
  }

  Future<List<Map<String, dynamic>>> getPosts() async {
    final db = await instance.database;
    final result = await db.query('posts');
    return result.map((post) {
      List<dynamic> comments = [];
      final commentsData = post['comments'];

      if (commentsData is String) {
        try {
          comments = json.decode(commentsData);
        } catch (e) {
          print('Error decoding comments JSON string: $e');
        }
      } else if (commentsData is Uint8List) {
        try {
          final commentsString = utf8.decode(commentsData);
          comments = json.decode(commentsString);
        } catch (e) {
          print('Error decoding comments JSON from bytes: $e');
        }
      }

      return {
        ...post,
        'comments': comments,
      };
    }).toList();
  }

  Future<void> deletePost(int id) async {
    final db = await instance.database;

    await db.delete(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllPosts() async {
    final db = await instance.database;

    await db.delete('posts');
  }

  Future<void> updateUser(Map<String, dynamic> user) async {
    final db = await instance.database;

    await db.update(
      'users',
      user,
      where: 'id = ?',
      whereArgs: [user['id']],
    );
  }

  Future<void> updateGender(int userId, String gender) async {
    final db = await instance.database;

    await db.update(
      'users',
      {'gender': gender},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updatePost(Map<String, dynamic> post) async {
    final db = await instance.database;
    final jsonString = json.encode(post['comments']);
    await db.update(
      'posts',
      {
        'id': post['id'] as int,
        'text': post['text'],
        'image': post['image'],
        'comments': jsonString,
      },
      where: 'id = ?',
      whereArgs: [post['id']],
    );
  }

  Future<void> updateProfilePicturePath(int userId, String path) async {
    final db = await instance.database;

    await db.update(
      'users',
      {'profilePicturePath': path},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updateProfilePicUrl(int userId, String url) async {
    final db = await instance.database;

    await db.update(
      'users',
      {'profilePicUrl': url},
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<void> updatePostInDatabase(Map<String, dynamic> post) async {
    final db = await instance.database;
    final jsonString = json.encode(post);
    final jsonBytes = utf8.encode(jsonString);
    await db.update(
      'posts',
      {
        'id': post['id'] as int,
        'text': post['text'],
        'image': post['image'],
        'comments': Uint8List.fromList(jsonBytes),
      },
      where: 'id = ?',
      whereArgs: [post['id']],
    );
  }
}
