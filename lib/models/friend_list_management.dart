import 'package:blockchain_messenger/models/user_model.dart';
import 'package:flutter/foundation.dart';

class FriendListModel with ChangeNotifier {
  List<SaveFriend> _friends = [];

  List<SaveFriend> get friends => _friends;

  void addFriend(SaveFriend friend) {
    _friends.add(friend);
    notifyListeners();
  }

  void loadFriends(List<SaveFriend> friends) {
  _friends = friends;
  notifyListeners();
}

}
