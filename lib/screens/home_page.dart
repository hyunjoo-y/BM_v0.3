import 'dart:convert';

import 'package:blockchain_messenger/components/constant.dart';
import 'package:blockchain_messenger/components/rounded_input_text_field.dart';
import 'package:blockchain_messenger/contracts/messenger_contract.dart';
import 'package:blockchain_messenger/database/dbHelper.dart';
import 'package:blockchain_messenger/models/contract_model.dart';
import 'package:blockchain_messenger/models/friend_list_management.dart';
import 'package:blockchain_messenger/models/user_model.dart';
import 'package:blockchain_messenger/screens/chat_page.dart';
import 'package:blockchain_messenger/screens/friend_page.dart';
import 'package:blockchain_messenger/screens/setting_page.dart';
import 'package:blockchain_messenger/widget/my_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:web3dart/web3dart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController tabController;
  DBHelper dbHelper = DBHelper();

  String userId = "";
  List<SaveFriend> friends = [];
  int currentTabIndex = 0;
  SaveFriend friend = SaveFriend(
      id: '',
      name: '',
      avatar: [],
      status: '',
      profileHash: '',
      nodeAddr: '',
      pubKey: '');

  final String contractAddress = "0xC2A811172D7381Edf5edD85445Feb2Cd212B49f0";
  final String blockchainUrl = "http://115.85.181.212:30011";
  final String priv =
      "778f4905fcee27222ef12e05885d5edf740a5bf2881e4340c9379a4cf99c711c";

  late http.Client httpClient;
  late Web3Client ethClient;
  late Contracts contract;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);

    tabController.addListener(() {
      onTabChange();
    });

    httpClient = http.Client();
    ethClient = Web3Client(blockchainUrl, httpClient);
    contract = Contracts(
        client: ethClient,
        abiJson: 'assets/smartcontracts/user_contract.json',
        contractAddress: contractAddress,
        contractName: "MessengerContract",
        privateKey: priv);
    super.initState();
  }

  @override
  void dispose() {
    tabController.addListener(() {
      onTabChange();
    });
    tabController.dispose();
    super.dispose();
  }

  void onTabChange() {
    setState(() {
      currentTabIndex = tabController.index;
      print(currentTabIndex);
    });
  }

  Future<List<int>> getImageBytes(String imagePath) async {
    final ByteData imageData = await rootBundle.load(imagePath);
    return imageData.buffer.asUint8List();
  }

  Future<SaveFriend> downloadFileFromIPFS(String friendId) async {
    String cid = await getUserProfileHash(contract, friendId);
    print('cid $cid');
    final url = 'https://testmessenger.infura-ipfs.io/ipfs/$cid';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print('object');
      final responseBody = response.body;
      print('body $responseBody');
      final jsonMap = json.decode(responseBody);
      final userId = jsonMap['userId']; // userId 키에 해당하는 값 가져오기
      final username = jsonMap['username']; // username 키에 해당하는 값 가져오기
      final stateMessage = jsonMap['stateMessage'];
      final nodeAddress = jsonMap['nodeAddress'];
      final publicKey = jsonMap['publicKey'];

      final encodedImageData =
          jsonMap['imageData']; // imageData 키에 해당하는 Base64로 인코딩된 이미지 데이터 가져오기
      final imageData = base64Decode(
          encodedImageData); // Base64로 인코딩된 이미지 데이터를 디코드하여 바이트 데이터로 변환

      SaveFriend frUserObject = SaveFriend(
          id: userId,
          name: username,
          avatar: imageData,
          status: stateMessage,
          profileHash: cid,
          nodeAddr: nodeAddress,
          pubKey: publicKey);

      return frUserObject;
    } else {
      throw Exception(
          'Failed to download file from IPFS. Status code: ${response.statusCode}');
    }
  }

  Future<void> _addFriend() async {
    final Size size = MediaQuery.of(context).size;
    final TextEditingController userIdController = TextEditingController();
    var ava = await getImageBytes('assets/profile.png');
    friend = SaveFriend(
        id: '',
        name: '',
        avatar: ava,
        status: '',
        profileHash: '',
        nodeAddr: '',
        pubKey: '');
    setState(() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            // Add StatefulBuilder to manage the state of the dialog
            builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                title: Text('Add Friend'),
                content: SingleChildScrollView(
                  child: Container(
                    child: Column(
                      children: [
                        RoundedTextField(
                          hintText: 'User ID',
                          color: Color.fromRGBO(237, 237, 237, 1),
                          hintColor: Colors.black38,
                          onChanged: (String value) {
                            userId = value;
                          },
                        ),
                        SizedBox(
                          height: size.height * 0.05,
                        ),
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.white,
                              backgroundImage: MemoryImage(
                                  Uint8List.fromList(friend.avatar)),
                              radius: 40,
                            ),
                            SizedBox(
                              width: size.width * 0.03,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  friend.name,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  friend.status,
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Search',
                        style: TextStyle(color: Colors.grey)),
                    onPressed: () async {
                      try {
                        SaveFriend frUserValue =
                            await downloadFileFromIPFS(userId);
                        setState(() {
                          friend = frUserValue;
                          print('object: ${friend.id}');
                        
                        });
                      } catch (e) {
                        // Error handling
                        print('오류 발생: $e');
                      }
                    },
                  ),
                  TextButton(
                    child: const Text('add'),
                    onPressed: () async {
                      FriendListModel friendListProvider =
                          Provider.of<FriendListModel>(context, listen: false);
                      friendListProvider.addFriend(friend);
                      //await dbHelper.insertFriend(friend);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime? _lastPressedAt;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: homeColor,
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
        title: Text(
          'Messenger',
          style: GoogleFonts.doHyeon(fontSize: 35, fontWeight: FontWeight.w700),
        ),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.settings))],
        elevation: 0,
      ),
      backgroundColor: homeColor,
      body: WillPopScope(
        onWillPop: () async {
          if (_lastPressedAt == null ||
              DateTime.now().difference(_lastPressedAt!) >
                  Duration(seconds: 2)) {
            // 첫 번째 뒤로가기 버튼 클릭 시
            _lastPressedAt = DateTime.now();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                backgroundColor: Colors.grey,
                content: const Text('한 번 더 누르시면 종료됩니다.'),
                duration: Duration(seconds: 2),
              ),
            );
            return false;
          } else {
            // 두 번째 뒤로가기 버튼 클릭 시
            SystemChannels.platform.invokeMethod('SystemNavigator.pop');
            return true; // 앱 종료
          }
        },
        child: Column(
          children: [
            MyTabBar(tabController: tabController),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: TabBarView(
                  controller: tabController,
                  children: [
                    FriendPage(
                      friends: friends,
                    ),
                    //Center(child: Text('Friends')),
                    ChatPage(),
                    SettingPage()
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        backgroundColor: homeColor,
        onPressed: () {
          setState(() {
            if (currentTabIndex == 0) {
              _addFriend();
            } else if (currentTabIndex == 1) {
              setState(() {
                /*Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => SelectChatFriendPage(),
                 ),
                );*/
              });
            } else {}
            // currentTabIndex == 0? _addFriend() : currentTabIndex == 1? Icons.message_rounded: Icons.settings;
          });
        },
        child: Icon(currentTabIndex == 0
            ? Icons.plus_one
            : currentTabIndex == 1
                ? Icons.message_rounded
                : Icons.settings),
      ),
    );
  }
}
