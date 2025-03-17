import 'package:blockchain_messenger/widget/friend_list_page.dart';
import 'package:flutter/material.dart';
import 'package:blockchain_messenger/models/user_model.dart';


class FriendPage extends StatefulWidget {
  final List<SaveFriend> friends;

  const FriendPage({Key? key, required this.friends}) : super(key: key);

  @override
  State<FriendPage> createState() => _FriendPageState();
}

class _FriendPageState extends State<FriendPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FriendsListPage(friends: widget.friends),
    );

  }
}