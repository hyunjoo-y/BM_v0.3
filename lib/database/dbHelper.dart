import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../models/message_model.dart';
import '../models/user_model.dart';

const String chatTableName = 'Chat';
const String roomTableName = 'ChatRoom';
const String userTableName = 'userInfo';
const String friendTableName = 'friendInfo';

class DBHelper {
  DBHelper._();
  static final DBHelper _db = DBHelper._();
  factory DBHelper() => _db;

  Database? _database;

  Future<Database> get database async {
    _database ??= await initDB();
    return _database!;
  }

  Future<Database> initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'ChatDB.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE IF NOT EXISTS $chatTableName(
          id INTEGER PRIMARY KEY,
          roomName TEXT,
          sender TEXT,
          receiver TEXT,
          message TEXT,
          timestamp TEXT,
          read INTEGER
        )
      ''');
        await db.execute('''
        CREATE TABLE IF NOT EXISTS $roomTableName(
          id INTEGER PRIMARY KEY,
          roomName TEXT,
          participants TEXT,
          lastMessage TEXT,
          timestamp TEXT
        )
      ''');
        await db.execute('''
        CREATE TABLE IF NOT EXISTS $userTableName(
          id TEXT PRIMARY KEY,
          nodeAddress TEXT,
          publicKey TEXT,
          username TEXT,
          avatar TEXT,
          status TEXT,
          profileHash TEXT
        )
      ''');
        await db.execute('''
        CREATE TABLE IF NOT EXISTS $friendTableName (
          id TEXT PRIMARY KEY,
          nodeAddress TEXT,   -- Add the nodeAddress column
          publicKey TEXT,
          username TEXT,
          avatar TEXT,
          status TEXT,
          profileHash TEXT
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) {},
    );
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      userTableName,
      {
        'id': user.id,
        'nodeAddress': user.nodeAddr,
        'publicKey': user.pubKey,
        'username': user.name,
        'avatar': user.avatar,
        'status': user.status,
        'profileHash': user.profileHash,
      },
    );
  }

  Future<void> insertFriend(SaveFriend friend) async {
    final db = await database;
    await db.insert(friendTableName, {
      'id': friend.id,
      'nodeAddress': friend.nodeAddr,
      'publicKey': friend.pubKey,
      'username': friend.name,
      'avatar': friend.avatar,
      'status': friend.status,
      'profileHash': friend.profileHash,
    });
  }

  Future<void> insertChat(String roomName, ChatFriend sender,
      ChatFriend receiver, Message message) async {
    final db = await database;
    await db.insert(
      chatTableName,
      {
        'roomName': roomName,
        'sender': sender,
        'receiver': receiver,
        'message': message.content,
        'timestamp': message.timestamp,
        'read': message.isRead
      },
    );
  }

  Future<void> saveRoomData(String roomName, List<ChatFriend> participants,
      Message lastMessage) async {
    final db = await database;
    await db.insert(
      roomTableName,
      {
        'roomName': roomName,
        'participants': participants,
        'lastMessage': lastMessage.content,
        'timestamp': lastMessage.timestamp,
      },
    );
  }

  Future<bool> isFriendAdded(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      friendTableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    // ID를 가진 친구가 존재하는지 확인
    return maps.isNotEmpty;
  }

  Future<List<SaveFriend>> getFriends() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(friendTableName);

    return List.generate(maps.length, (index) {
      return SaveFriend.fromMap(maps[index]);
    });
  }

  Future<int> getCountOfReadMessages() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) FROM $chatTableName WHERE read = 1');
    final count = Sqflite.firstIntValue(result);
    return count ?? 0;
  }

  Future<Map<String, int>> getReadCountByRoom() async {
    final db = await database;
    final result = await db.rawQuery('''
    SELECT $roomTableName.roomName, COUNT(*) AS readCount
    FROM $roomTableName
    LEFT JOIN $chatTableName ON $roomTableName.roomName = $chatTableName.roomName AND $chatTableName.read = 1
    GROUP BY $roomTableName.roomName
  ''');

    final readCounts = <String, int>{};

    for (final row in result) {
      final roomName = row['roomName'] as String;
      final count = row['readCount'] as int;
      readCounts[roomName] = count ?? 0;
    }

    return readCounts;
  }

  Future<SaveFriend?> getFriendById(String id) async {
    final db = await database;
    List<Map<String, dynamic>>? results = await db.query(
      friendTableName,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results != null && results.isNotEmpty) {
      Map<String, dynamic> friendData = results.first;

      // User 객체 생성 및 데이터 매핑
      SaveFriend friend = SaveFriend(
        id: friendData['id'],
        nodeAddr: friendData['nodeAddr'],
        pubKey: friendData['pubKey'],
        name: friendData['name'],
        avatar: friendData['avatar'],
        status: friendData['status'],
        profileHash: friendData['profileHash'],
      );

      return friend;
    }

    return null;
  }

  Future<List<Message>> getAllChats(String roomName) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(chatTableName);

    return result
        .map((map) => Message(
              ChatFriend.fromMap(map['sender']),
              ChatFriend.fromMap(map['receiver']),
              map['isRead'],
              map['content'],
              map['timestamp'],
            ))
        .toList();
  }

  Future<List<ChatRoomModel>> getAllRooms() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(roomTableName);

    return List.generate(result.length, (index) {
      final map = result[index];
      final roomName = map['roomName'] as String;
      final participants = (map['participants'] as List<ChatFriend>);
      final lastMessage = map['lastMessage'] as Message;

      return ChatRoomModel(roomName, participants[0], lastMessage);
    });
  }
}
