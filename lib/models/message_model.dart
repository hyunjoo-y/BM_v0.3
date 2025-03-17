import 'package:blockchain_messenger/models/user_model.dart';

class Message {
  ChatFriend sender;
  ChatFriend receiver;

  bool isRead;
  String content;
  String timestamp;

  Message(
      this.sender, this.receiver, this.isRead, this.content, this.timestamp);

  Map<String, dynamic> toMap() {
    return {
      'sender': sender.toMap(),
      'receiver': receiver.toMap(),
      'message': content,
      'timestamp': timestamp,
    };
  }
/*
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      sender: frUser.fromMap(map['sender']),
      receiver: frUser.fromMap(map['receiver']),
      message: map['message'],
      timestamp: map['timestamp'],
    );
  }*/
}


class ChatRoomModel {
  String roomName;
  ChatFriend chatFriend;
  Message lastMassage;

  ChatRoomModel(this.roomName, this.chatFriend, this.lastMassage);

  Map<String, dynamic> toMap() {
    return {
      'roomName': roomName,
      'chatFriend': chatFriend.toMap(),
      'lastMessage': lastMassage,
    };
  }

}
