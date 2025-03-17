import 'dart:convert';

class User {
  String id;
  String nodeAddr;
  String pubKey;
  String name;
  List<int> avatar;
  String status;
  String profileHash;

  User(
      {required this.id,
      required this.nodeAddr,
      required this.pubKey,
      required this.name,
      required this.avatar,
      required this.status,
      required this.profileHash});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'status': status,
      'profileHash': profileHash,
      'nodeAddr': nodeAddr,
      'pubKey': pubKey
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      avatar: (map['avatar'] as List<dynamic>).cast<int>(),
      status: map['status'],
      profileHash: map['profileHash'],
      nodeAddr: map['nodeAddr'],
      pubKey: map['pubKey'],
    );
  }
}

class ChatFriend {
  String name;
  String id;
  String nodeAddr;
  List<int> avatar;

  ChatFriend({
    required this.name,
    required this.id,
    required this.nodeAddr,
    required this.avatar,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'id': id};
  }

  String toJson() {
    return json.encode(toMap());
  }

  static ChatFriend fromMap(Map<String, dynamic> map) {
    return ChatFriend(
      name: map['name'],
      id: map['id'],
      nodeAddr: map['nodeAddr'],
      avatar: (map['avatar'] as List<dynamic>).cast<int>(),
    );
  }

  static ChatFriend fromJson(String json) {
    return fromMap(jsonDecode(json));
  }
}

class SaveFriend {
  String id;
  String nodeAddr;
  String pubKey;
  String name;
  List<int> avatar;
  String status;
  String profileHash;

  SaveFriend(
      {required this.id,
      required this.nodeAddr,
      required this.pubKey,
      required this.name,
      required this.avatar,
      required this.status,
      required this.profileHash});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nodeAddr': nodeAddr,
      'pubKey': pubKey,
      'name': name,
      'avatar': avatar,
      'status': status,
      'profileHash': profileHash
    };
  }

  factory SaveFriend.fromMap(Map<String, dynamic> map) {
    return SaveFriend(
      id: map['id'] ?? '', // 기본값 또는 빈 문자열로 설정
      nodeAddr: map['nodeAddr'] ?? '', // 기본값 또는 빈 문자열로 설정
      pubKey: map['pubKey'] ?? '', // 기본값 또는 빈 문자열로 설정
      name: map['name'] ?? '', // 기본값 또는 빈 문자열로 설정
      avatar: (map['avatar'] as List<dynamic>?)?.cast<int>() ??
          <int>[], // 기본값은 빈 List
      status: map['status'] ?? '', // 기본값 또는 빈 문자열로 설정
      profileHash: map['profileHash'] ?? '', // 기본값 또는 빈 문자열로 설정
    );
  }
}
