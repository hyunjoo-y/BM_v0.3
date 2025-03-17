import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blockchain_messenger/components/constant.dart';
import 'package:blockchain_messenger/database/dbHelper.dart';
import 'package:blockchain_messenger/models/chat_provider_model.dart';
import 'package:blockchain_messenger/models/contract_model.dart';
import 'package:blockchain_messenger/models/message_model.dart';
import 'package:blockchain_messenger/models/user_model.dart';
import 'package:blockchain_messenger/widget/conversation.dart';
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({Key? key, required this.frUser}) : super(key: key);
  final ChatFriend frUser;

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final String blockchainUrl = "http://115.85.181.212:30011";
  late http.Client httpClient;
  late Web3Client ethClient;
  late Contracts contract;
  final String contracAddr = "0xC2A811172D7381Edf5edD85445Feb2Cd212B49f0";
  final String priv =
      "ff0fa49c7c7d4ed501ecca1cd58f996c81ab0ff1ff53551d2b8bbe880b578056";

  DBHelper dbHelper = DBHelper();

  late RTCDataChannel _dataChannel;
  late IO.Socket newSocket;
  RTCPeerConnection? pc;
  String roomId = '';
  late var connectData;

  // file
  String fileName = '';

  List<Message> savedMsg = [];
  List<int> receivedData = [];

  ChatFriend currentUser =
      ChatFriend(name: '', id: '', avatar: [], nodeAddr: '');
  late Message firstMessage;
  late var chatProvider;

  DateTime? connectionStartTime;

  @override
  void initState() {
    setCurrentUser();
    init();
    super.initState();
  }

  @override
  void dispose() {
    newSocket.dispose();
    pc?.dispose();
    super.dispose();
  }

  Future init() async {
    httpClient = http.Client();
    ethClient = Web3Client(blockchainUrl, httpClient);
    contract = Contracts(
        client: ethClient,
        abiJson: 'assets/smartcontracts/user_contract.json',
        contractAddress: contracAddr,
        contractName: "MessengerContract",
        privateKey: priv);

    await connectSocket();
    getRoomId();
    Message firstMessage = Message(currentUser, widget.frUser, false, '', '');
    updateLastMessage(widget.frUser, firstMessage);

    await joinRoom();
  }



  Future<void> setCurrentUser() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/profile_data.json');

    if (await file.exists()) {
      // 파일이 존재하는지 확인

      final jsonString = await file.readAsString();

      if (jsonString.isNotEmpty) {
        // 파일이 비어 있지 않은 경우

        final Map<String, dynamic> data = json.decode(jsonString);
        final imageBytes = base64.decode(data['imageData']);

        // 이제 "data" 맵을 사용하여 필요한 정보에 접근할 수 있습니다.
        currentUser.id = data['userId'];
        currentUser.nodeAddr = data['nodeAddress'];
        currentUser.name = data['username'];
        currentUser.avatar = imageBytes;
      } else {
        // 파일이 비어있는 경우 또는 JSON 파싱에 실패한 경우
        print('JSON 데이터가 비어 있거나 파싱에 실패했습니다.');
      }
    } else {
      // 파일이 존재하지 않는 경우
      print('파일이 존재하지 않습니다.');
    }
  }

  void updateLastMessage(ChatFriend _chatFriend, Message _lastMessage) {
    // ChatProvider를 가져옵니다.
    chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // 채팅방 정보를 업데이트
    chatProvider.updateChatRoom(_chatFriend, _lastMessage);
    ChatRoomModel currentChat =
        ChatRoomModel(roomId, widget.frUser, _lastMessage);

    // 채팅방이 목록에 없는 경우에만 추가
    if (!chatProvider.chatRooms
        .any((room) => room.chatFriend.id == _chatFriend.id)) {
      chatProvider.setChatRooms(currentChat);
    }
  }

  void getRoomId() async {
    String peer1 = widget.frUser.name;
    String peer2 = currentUser.name; // me
    int result = peer1.compareTo(peer2);
    if (result < 0) {
      roomId = peer1 + peer2;
    } else {
      roomId = peer2 + peer1;
    }
  }

  Future joinRoom() async {
    connectionStartTime = DateTime.now();

    // 여기를 릴레이 노드 주소로 변경
    // 스마트 컨트랙트에서 받아오기
    final config = {
      'iceServers': [
        {"url": "stun:stun.l.google.com:19302"},
      ]
    };

    pc = await createPeerConnection(config);

    pc!.onIceCandidate = (ice) {
      // ice 를 상대방에게 전송
      onIceGenerated(ice);
    };

    pc!.onDataChannel = (channel) {
      _addDataChannel(channel);
    };

    newSocket.emit('checkNode', widget.frUser.nodeAddr);
  }

  Future connectSocket() async {
    try {
      // var relay = await getRelayIp(contract);
      newSocket = IO.io(
        "http://115.85.181.212:30005",
        // "http://115.85.181.212:30020",
        IO.OptionBuilder().setTransports(['websocket']).build(),
      );

      newSocket.onConnect((data) {
        print('connect!');
        newSocket.emit('setNodeAddr', currentUser.nodeAddr);
      });

      initializeSocketListeners();
    } catch (error) {
      print('Socket 연결 실패: $error');
    }
    // initializeSocketListeners();
  }

  void initializeSocketListeners() {
    newSocket.on('joined', (data) {
      print(': socket--joined / $data');
      onReceiveJoined();
    });

    newSocket.on('offer', (data) {
      print(': listener--offer');
      onReceiveOffer(data);
    });

    newSocket.on('answer', (data) {
      print(' : socket--answer');
      onReceiveAnswer(data);
    });

    newSocket.on('ice', (data) {
      print(': socket--ice');
      onReceiveIce(data);
    });
  }

  void onReceiveJoined() {
    _sendOffer();
  }

  Future<void> _connectToNode(String targetNodeAddr) async {
    final offer = await pc!.createOffer();
    pc!.setLocalDescription(offer);

    connectData = {
      'nodeAddr': targetNodeAddr,
      'sender': currentUser.nodeAddr,
      'offer': offer.toMap(),
    };

    newSocket.emit('offer', connectData);
  }

  Future _sendOffer() async {
    print('send offer to ');
    await _createDataChannel();
    _connectToNode(widget.frUser.nodeAddr);
  }

  Future<void> _createDataChannel() async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit();
    RTCDataChannel? channel =
        await pc?.createDataChannel(roomId, dataChannelDict);

    _addDataChannel(channel!);
  }

  void _addDataChannel(RTCDataChannel channel) {
    _dataChannel = channel;

    _dataChannel.onMessage = (data) async {
      initializeDateFormatting('ko_KR', null);
      var now = DateTime.now();
      var time = DateFormat('kk:mm', 'ko').format(now).toString();

      final message = data.text;

      if (message.startsWith('fileName')) {
        // 파일 이름 수신
        fileName = message.substring(8); // 파일 이름 추출
      } else if (message.startsWith('fileData')) {
        // 파일 데이터 수신
        var fileData = message.substring(8); // 파일 데이터 추출
        List<int> bytess = base64Decode(fileData);
        receivedData += bytess;
        print('Receiver: $fileData');
      } else if (message.startsWith('fileLast')) {
        var fileData = message.substring(8); // 파일 데이터 추출
        List<int> bytess = base64Decode(fileData);
        receivedData += bytess;
        print('Receiver: $fileData');
        // 확장자 추출
        final fileExtension = fileName.split('.').last;
        // 파일 저장 처리
        await saveFile(receivedData, fileName);

        await sendMessage('$fileName 다운로드 완료');
        setState(() {
          savedMsg.insert(
            0,
            Message(
                widget.frUser, currentUser, true, '$fileName 다운로드 완료', time),
          );
        });
        receivedData = []; // 데이터 초기화
        fileName = ''; // 파일 이름 초기화
      } else if (message.startsWith('textData')) {
        // 텍스트 데이터 수신
        final textData = message.substring(8); // 텍스트 데이터 추출
        print('텍스트 데이터 수신: $textData');
        setState(() {
          savedMsg.insert(
            0,
            Message(widget.frUser, currentUser, true, textData, time),
          );
        });
      }
    };

    _dataChannel.onDataChannelState = (state) {
      // 연결 설정
      if (connectionStartTime != null) {
        final connectionEndTime = DateTime.now();
        final connectionDuration =
            connectionEndTime.difference(connectionStartTime!).inMilliseconds;
        print('연결 설정 시간: $connectionDuration 밀리초');
      }

      // state.toString();
      print('open ${state.toString()}');
    };
  }

  Future<void> sendMessage(String message) async {
    await _dataChannel.send(RTCDataChannelMessage('textData$message'));
  }

  Future<void> onReceiveOffer(data) async {
    final Map<String, dynamic> offerData = data['offer'];

    final offer = RTCSessionDescription(offerData['sdp'], offerData['type']);

    pc!.setRemoteDescription(offer);

    final answer = await pc!.createAnswer();
    pc!.setLocalDescription(answer);

    _sendAnswer(data['sender'], answer);
  }

  Future _sendAnswer(String targetNodeAddr, answer) async {
    print(': send answer');
    final Map<String, dynamic> answerData = {
      'nodeAddr': widget.frUser.nodeAddr,
      'sender': currentUser.nodeAddr,
      'answer': answer.toMap()
    };

    newSocket.emit('answer', answerData);
  }

  Future onReceiveAnswer(data) async {
    print('  --got answer');
    setState(() {});
    final Map<String, dynamic> answerData = data['answer'];

    final answer = RTCSessionDescription(answerData['sdp'], answerData['type']);
    pc!.setRemoteDescription(answer);
  }

  Future onIceGenerated(RTCIceCandidate ice) async {
    print('send ice ');
    print(ice.candidate.toString());
    print(ice.sdpMid.toString());

    final Map<String, dynamic> iceData = {
      'nodeAddr': widget.frUser.nodeAddr,
      'sender': currentUser.nodeAddr,
      'candidate': ice.toMap()
    };

    newSocket.emit('ice', iceData);
  }

  Future onReceiveIce(data) async {
    print('   --got ice');
    final Map<String, dynamic> iceData = data['candidate'];

    final ice = RTCIceCandidate(
      iceData['candidate'],
      iceData['sdpMid'],
      iceData['sdpMLineIndex'],
    );
    pc!.addCandidate(ice);
  }

  void sendFileData(File file) async {
    //const chunkSize = 65535; // 64 KB
    const chunkSize = 131072; // 16KB
    final bytes = await file.readAsBytes();

    final fileName = file.path.split('/').last; // 파일 이름 추출
    print('filename: $fileName');

    // 파일 이름 전송
    await _dataChannel.send(RTCDataChannelMessage('fileName$fileName'));

    for (var i = 0; i < bytes.length; i += chunkSize) {
      final isLastChunk = (i + chunkSize) >= bytes.length;
      final chunk = bytes.sublist(i, i + chunkSize.clamp(0, bytes.length - i));
      final base64Chunk = base64Encode(chunk);

      print('Sender: $base64Chunk');

      if (isLastChunk) {
        await _dataChannel.send(RTCDataChannelMessage('fileLast$base64Chunk'));
      } else {
        await _dataChannel.send(RTCDataChannelMessage(base64Chunk));
        await _dataChannel.send(RTCDataChannelMessage('fileData$base64Chunk'));
      }
    }

    await _dataChannel.send(RTCDataChannelMessage('transferComplete'));
  }

  Future<void> saveFile(List<int> fileBytes, String fileName) async {
    //final directory = await getApplicationDocumentsDirectory();
    //final filePath = '${directory.path}/$fileName';
    final directory = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS);
    final filePath = '$directory/$fileName';

    File file = File(filePath);
    await file.writeAsBytes(fileBytes);
    print('파일 저장 완료: $filePath');
  }

  void getImageBytes() async {
    final ByteData imageData = await rootBundle.load('assets/sslab.jpg');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    TextEditingController text = TextEditingController();

    return Scaffold(
      appBar: AppBar(
          backgroundColor: buttonColor,
          toolbarHeight: size.height * 0.08,
          centerTitle: false,
          title: Row(children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 30,
              backgroundImage:
                  MemoryImage(Uint8List.fromList(widget.frUser.avatar)),
            ),
            SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.frUser.name,
                  style: GoogleFonts.heebo(
                      letterSpacing: 1.5, fontWeight: FontWeight.bold),
                ),
                Text(
                  'online',
                  style: GoogleFonts.heebo(letterSpacing: 1.5, fontSize: 11),
                )
              ],
            )
          ]),
          actions: [
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.call,
                  size: 20,
                ))
          ],
          elevation: 0),
      backgroundColor: buttonColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Expanded(
                child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15)),
                child: Conversation(
                  other: widget.frUser,
                  msg: savedMsg,
                  isSend: false,
                  currentUser: currentUser,
                ),
              ),
            )),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              color: Colors.white,
              height: 100,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      height: size.height * 0.5,
                      // margin: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(30)),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              initializeDateFormatting('ko_KR', null);
                              var now = DateTime.now();
                              var time = DateFormat('kk:mm', 'ko')
                                  .format(now)
                                  .toString();

                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles();
                              if (result != null && result.files.isNotEmpty) {
                                PlatformFile file = result.files.first;
                                File selectedFile = File(file.path!);

                                setState(() {
                                  // 파일 데이터 전송
                                  sendFileData(selectedFile);
                                  savedMsg.insert(
                                    0,
                                    Message(
                                        currentUser,
                                        widget.frUser,
                                        true,
                                        '${selectedFile.path.split('/').last} 전송 완료',
                                        time),
                                  );
                                  Conversation(
                                    other: widget.frUser,
                                    isSend: true,
                                    msg: savedMsg,
                                    currentUser: currentUser,
                                  );
                                });
                              }
                            },
                            icon: Icon(
                              Icons.file_copy_outlined,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: TextField(
                              controller: text,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Type the Message...',
                                  hintStyle:
                                      TextStyle(color: Colors.grey[500])),
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          IconButton(
                              onPressed: () {},
                              icon: Icon(
                                Icons.mic,
                                color: Colors.grey[500],
                              ))
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  CircleAvatar(
                    backgroundColor: buttonColor,
                    child: IconButton(
                      onPressed: () {
                        initializeDateFormatting('ko_KR', null);
                        var now = DateTime.now();
                        var time =
                            DateFormat('kk:mm', 'ko').format(now).toString();
                        print('send: $time');
                        setState(() {
                          sendMessage(text.text);
                          savedMsg.insert(
                              0,
                              Message(currentUser, widget.frUser, true,
                                  text.text, time));
                          setState(() {
                            Conversation(
                              other: widget.frUser,
                              isSend: true,
                              msg: savedMsg,
                              currentUser: currentUser,
                            );
                          });
                        });
                      },
                      icon: Icon(
                        Icons.send,
                        color: Colors.grey[200],
                      ),
                    ),
                  )
                ],
              ),
            )
            //Container(child: ChatComposer(msg: msg,socket: socket,))
          ],
        ),
      ),
    );
  }
}
