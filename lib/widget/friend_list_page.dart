import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:blockchain_messenger/database/dbHelper.dart';
import 'package:blockchain_messenger/models/chat_provider_model.dart';
import 'package:blockchain_messenger/models/friend_list_management.dart';
import 'package:blockchain_messenger/screens/chat_room_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../components/constant.dart';
import 'package:blockchain_messenger/models/user_model.dart';

class FriendsListPage extends StatefulWidget {
  final List<SaveFriend> friends;
  const FriendsListPage({Key? key, required this.friends}) : super(key: key);

  @override
  _FriendsListPageState createState() => _FriendsListPageState();
}

class _FriendsListPageState extends State<FriendsListPage> {
  DBHelper dbHelper = DBHelper();
  List<SaveFriend> friends = [];

  @override
  void initState() {
    super.initState();
  }


  // Future<void> _loadFriends() async {
  //   friends = await dbHelper.getFriends(); 
  //   print('friend[0]: ${friends[0].id}');
  //   FriendListModel friendListProvider = Provider.of<FriendListModel>(context, listen: false);
  //   friendListProvider.loadFriends(friends);
  // }

  /// show Friend's Profile
  void _showChatBottomSheet(BuildContext context, SaveFriend friend) {
    final Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage:
                        MemoryImage(Uint8List.fromList(friend.avatar)),
                    radius: 50,
                  ),
                  SizedBox(width: size.width * 0.03),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(friend.name,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(friend.status, style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Container(
                color: Colors.black26,
                height: 1,
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              ChatFriend chatFriend = ChatFriend(
                                  name: friend.name,
                                  id: friend.id,
                                  nodeAddr: friend.nodeAddr,
                                  avatar: friend.avatar);
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return ChatRoom(
                                  frUser: chatFriend,
                                );
                              }));
                            });
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            padding: const EdgeInsets.only(top: 5),
                            child: const Image(
                              image: AssetImage('assets/chat.png'),
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('Chat')
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // 아이콘을 클릭할 때 실행할 동작
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            padding: const EdgeInsets.all(5),
                            child: const Image(
                              image: AssetImage('assets/audio.png'),
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('Voice')
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // 아이콘을 클릭할 때 실행할 동작
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            padding: const EdgeInsets.all(10),
                            child: const Image(
                              image: AssetImage('assets/video.png'),
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text('Video')
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(top: 30),
          child: Row(
            children: [
              Text(
                'Friends',
                style: GoogleFonts.abel(
                    fontWeight: FontWeight.w800,
                    fontSize: 25,
                    color: homeTextColor),
              ),
              Spacer(),
              Icon(Icons.search, color: homeTextColor),
            ],
          ),
        ),
        Consumer<FriendListModel>(
          builder: (context, friendListProvider, child) {
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: friendListProvider.friends.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  contentPadding:
                      EdgeInsets.only(left: size.width * 0.0001, right: 16.0),
                  leading: Container(
                    width: 80,
                    height: 80,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: MemoryImage(Uint8List.fromList(
                            friendListProvider.friends[index].avatar)),
                        radius: 40,
                      ),
                    ),
                  ),
                  title: Text(friendListProvider.friends[index].name),
                  subtitle: Text(friendListProvider.friends[index].status),
                  onTap: () {
                    _showChatBottomSheet(
                        context, friendListProvider.friends[index]);
                    // 클릭한 친구의 프로필 페이지로 이동
                    //Navigator.push(context, MaterialPageRoute(builder: (context) => FriendProfilePage(friend: friends[index])));
                  },
                );
              },
            );
          },
        )
      ],
    );
  }
}
