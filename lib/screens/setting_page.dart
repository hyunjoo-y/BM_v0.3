import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:blockchain_messenger/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  ChatFriend currentUser =
      ChatFriend(name: '', id: '', avatar: [], nodeAddr: '');

  bool notifiValue = true;

  onChangeFunction(bool value) {
    setState(() {
      notifiValue = value;
    });
  }

  @override
  void initState() {
    setCurrentUser();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
        child: Column(
      children: <Widget>[
        const SizedBox(
          height: 20,
        ),
        Column(
          children: [
            GestureDetector(
              onTap: () {
                // edit profile page
              },
              child: Container(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Row(children: [
                  CircleAvatar(
                    backgroundImage:
                        MemoryImage(Uint8List.fromList(currentUser.avatar)),
                    radius: 50,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentUser.name,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(
                          height: 15,
                        ),
                        const Text('Edit the profile',
                            style: TextStyle(fontSize: 15, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios)
                ]),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        Container(
          alignment: Alignment.topLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Notifiactions',
                  textAlign: TextAlign.start,
                  style: TextStyle(fontSize: 20, color: Colors.black45)),
              Container(
                  padding: EdgeInsets.only(top: 15),
                  child: GestureDetector(
                    onTap: () {
                      // Notfication
                    },
                    child: Row(children: [
                      buildNotificaitonOption(
                          "Notification", notifiValue, onChangeFunction, size)
                    ]),
                  )),
            ],
          ),
        )
      ],
    ));
  }

  Row buildNotificaitonOption(
      String title, bool value, Function onChangeMethod, Size size) {
    return Row(
      children: [
        const Icon(Icons.notifications),
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Text(
            title,
            style: const TextStyle(fontSize: 15, color: Colors.black45),
          ),
        ),
        SizedBox(width: size.width *0.45),
        Transform.scale(
          scale: 0.7,
          child: CupertinoSwitch(
              activeColor: Colors.blueGrey,
              trackColor: Colors.grey,
              value: value,
              onChanged: (bool newValue) {
                onChangeMethod(newValue);
              }),
        )
      ],
    );
  }
}
