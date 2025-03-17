import 'package:flutter/material.dart';
import 'package:blockchain_messenger/widget/recent_chat_list_page.dart';


class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          RecentChats(),
          // AllChats(),
        ],
      ),
    );
  }
}
