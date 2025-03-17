import 'package:blockchain_messenger/components/constant.dart';
import 'package:blockchain_messenger/database/dbHelper.dart';
import 'package:blockchain_messenger/models/message_model.dart';
import 'package:blockchain_messenger/models/user_model.dart';
import 'package:blockchain_messenger/screens/chat_room_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/chat_provider_model.dart';

class RecentChats extends StatefulWidget {
  const RecentChats({super.key});

  @override
  State<RecentChats> createState() => _RecentChatsState();
}

class _RecentChatsState extends State<RecentChats> {
  DBHelper dbHelper = DBHelper();
  
  late int count = 0;
  late var readCounts;
  late List<ChatRoomModel> recentChats = [];

  @override
  void initState(){
    super.initState();
    // receivedMsg();
  }


  
  Future<List<int>> getImageBytes(String imagePath) async {
    final ByteData imageData = await rootBundle.load(imagePath);
    return imageData.buffer.asUint8List();
  }

   @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 30),
          child: Row(
            children: [
              Text(
                'Recent Chats',
                style: GoogleFonts.abel(
                  fontWeight: FontWeight.w800,
                  fontSize: 25,
                  color: homeTextColor,
                ),
              ),
              const Spacer(),
              const Icon(Icons.search, color: homeTextColor),
            ],
          ),
        ),
        Consumer<ChatProvider>( // 추가: ChatProvider를 사용하여 목록을 동적으로 업데이트
          builder: (context, chatProvider, child) {
            final chatRooms = chatProvider.chatRooms;
            return ListView.builder(
              shrinkWrap: true,
              physics: ScrollPhysics(),
              itemCount: chatRooms.length,
              itemBuilder: (context, int index) {
                final recentChat = chatRooms[index];
                return Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: MemoryImage(Uint8List.fromList(recentChat.chatFriend.avatar)),
                        radius: 30,
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatRoom(
                                frUser: recentChat.chatFriend,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              recentChat.chatFriend.name,
                              style: TextStyle(
                                color: Colors.black45,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              recentChat.lastMassage.content,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Spacer(),
                      // Column(
                      //   crossAxisAlignment: CrossAxisAlignment.end,
                      //   children: [
                      //     if (readCounts.containsKey(recentChat.chatFriend))
                      //       readCounts[recentChat.chatFriend] == 0
                      //           ? Icon(
                      //               Icons.done_all,
                      //               color: Colors.grey,
                      //             )
                      //           : CircleAvatar(
                      //               radius: 8,
                      //               backgroundColor: Colors.red,
                      //               child: Text(
                      //                 readCounts[recentChat.chatFriend].toString(),
                      //                 style: TextStyle(
                      //                   fontWeight: FontWeight.bold,
                      //                   fontSize: 8,
                      //                   color: Colors.white,
                      //                 ),
                      //               ),
                      //             ),
                      //     SizedBox(height: 10),
                      //     Text(
                      //       recentChat.lastMassage.timestamp,
                      //       style: TextStyle(
                      //         color: Colors.grey,
                      //         fontSize: 12,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}