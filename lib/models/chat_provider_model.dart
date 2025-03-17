import 'package:blockchain_messenger/models/message_model.dart';
import 'package:blockchain_messenger/models/user_model.dart';
import 'package:flutter/foundation.dart';

class ChatProvider with ChangeNotifier {
  late ChatRoomModel _selectedChat;
  List<ChatRoomModel> _chatRooms = [];

  ChatRoomModel get selectedChat => _selectedChat;
  List<ChatRoomModel> get chatRooms => _chatRooms;

  void selectChat(ChatRoomModel chat) {
    _selectedChat = chat;
    notifyListeners();
  }

  void setChatRooms(ChatRoomModel newRoom) {
    if (!_chatRooms.any((room) => room.chatFriend.id == _selectedChat.chatFriend.id)) {
      _chatRooms.add(newRoom);
      notifyListeners(); // UI에 변경 사항을 알립니다.
    }

    notifyListeners();
  }

  void updateChatRoom(ChatFriend chatFriend, Message updateMessage) {
    // 업데이트된 채팅방 정보를 찾아서 업데이트
    final index = _chatRooms.indexWhere((room) => chatFriend.id == room.chatFriend.id);
    if (index != -1) {
      _chatRooms[index].lastMassage.content = updateMessage.content;
      _chatRooms[index].lastMassage.timestamp = updateMessage.timestamp;
      notifyListeners(); // UI에 변경 사항을 알립니다.
    }
  }
}
