import 'dart:typed_data';

import 'package:blockchain_messenger/components/constant.dart';
import 'package:blockchain_messenger/models/message_model.dart';
import 'package:blockchain_messenger/models/user_model.dart';
import 'package:flutter/material.dart';

class Conversation extends StatefulWidget {
  final ChatFriend other;
  final ChatFriend currentUser;
  final bool isSend;
  final List<Message> msg;

  const Conversation({Key? key, required this.other, required this.isSend, required this.msg, required this.currentUser,}) : super(key: key);
  

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return  ListView.builder(
        reverse: true,
        itemCount: widget.msg.length,
        itemBuilder: (context, int index) {
          final message = widget.msg[index];
          bool isMe = message.sender.id == widget.currentUser.id;
          return
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isMe)
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 15,
                            backgroundImage: MemoryImage(Uint8List.fromList(message.sender.avatar)),
                          ),
                        SizedBox(
                          width: 15,
                        ),
                        Container(
                            padding: EdgeInsets.all(13),
                            constraints: BoxConstraints(
                                maxWidth: size.width * 0.6),
                            decoration: BoxDecoration(
                                color: isMe
                                    ? buttonColor2
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(15),
                                    topRight: Radius.circular(15),
                                    bottomLeft: Radius.circular(
                                        isMe ? 15 : 0),
                                    bottomRight: Radius.circular(
                                        isMe ? 0 : 15))),
                            child: SelectableText(message.content))
                      ]),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isMe)
                          SizedBox(
                            width: 45,
                          ),
                        Icon(
                          Icons.done_all,
                          size: 15,
                          color: Colors.grey[500],
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          message.timestamp,
                          style: TextStyle(
                              color: Colors.grey, fontSize: 12),
                        )
                      ],
                    ),
                  )
                ],
              ));
        });

  }
}