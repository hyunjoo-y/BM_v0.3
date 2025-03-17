// ignore_for_file: avoid_unnecessary_containers, sort_child_properties_last, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:blockchain_messenger/models/metamask_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';

import 'package:android_id/android_id.dart';
import 'package:blockchain_messenger/components/import_blockchain_account_check.dart';
import 'package:blockchain_messenger/components/rounded_button.dart';
import 'package:blockchain_messenger/components/rounded_input_text_field.dart';
import 'package:blockchain_messenger/contracts/messenger_contract.dart';
import 'package:blockchain_messenger/models/contract_model.dart';
import 'package:blockchain_messenger/models/user_model.dart';
import 'package:blockchain_messenger/screens/welcome_page.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:blockchain_messenger/components/constant.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3dart/web3dart.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.user});
  final User user;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String username = "";
  String stateMessage = "";
  String profileHash = "";

  String imagePath = "";

  bool metaResult = false;
  bool metaLogin = false;

  late var _pubKey, _uri, wcClient;
  late ImageProvider<Object>? _image = null;
  late var _seed;
  final picker = ImagePicker();
  late var _imageBytes;
  var uuid = Uuid();
  late Web3App web3app;

  final String contractAddress = "0x89040b700913F8B3994875825fd23B7A63A2e7f9";
  final String blockchainUrl = "http://115.85.181.212:30011";
  final String priv =
      "778f4905fcee27222ef12e05885d5edf740a5bf2881e4340c9379a4cf99c711c";

  late Client httpClient;
  late Web3Client ethClient;
  late Contracts contract;

  @override
  void initState() {
    _image = AssetImage('assets/profile.png');
    httpClient = Client();
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
    super.dispose();
  }

  Future<void> _generateNodeAddr() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      _seed = iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      const _androidIdPlugin = AndroidId();
      _seed = await _androidIdPlugin.getId(); // Await the result
    }
    var nodeAddr = uuid.v5(Uuid.NAMESPACE_URL, _seed);
    widget.user.nodeAddr = nodeAddr;
    print('nodeAddr: ${widget.user.nodeAddr}');
  }

  Future<void> _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        _image = FileImage(File(pickedFile.path));
        _imageBytes = imageFile.readAsBytesSync();
        widget.user.avatar = _imageBytes;
      } else {
        print('No image selected.');
      }
    });
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Container(
        height: 100,
        width: 100,
        child: new Row(
          children: [
            CircularProgressIndicator(
              color: homeTextColor,
            ),
            Container(
                margin: EdgeInsets.only(left: 7), child: Text("Loading...")),
          ],
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void signupWithMetamask() async {
    final Web3App web3app = await Web3App.createInstance(
      projectId: '79d88517a3032f1cb467d5d642758156',
      metadata: const PairingMetadata(
        name: 'Flutter WalletConnect',
        description: 'Flutter WalletConnect Dapp Example',
        url: 'https://walletconnect.com/',
        icons: [
          'https://walletconnect.com/walletconnect-logo.png',
        ],
      ),
    );

    final ConnectResponse response = await web3app.connect(
      requiredNamespaces: {
        'eip155': const RequiredNamespace(
          chains: [
            'eip155:1',
          ],
          methods: [
            'personal_sign',
            'eth_sign',
            'eth_signTransaction',
            'eth_signTypedData',
            'eth_sendTransaction',
          ],
          events: [
            'chainChanged',
            'accountsChanged',
          ],
        ),
      },
    );

    final Uri? uri = response.uri;
    if (uri != null) {
      final String encodedUri = Uri.encodeComponent('$uri');

      await launchUrlString(
        'metamask://wc?uri=$encodedUri',
        mode: LaunchMode.externalApplication,
      );

      SessionData session = await response.session.future;

      String account = NamespaceUtils.getAccount(
        session.namespaces.values.first.accounts[0],
      );
      showLoaderDialog(context);
      _pubKey = account;
      widget.user.pubKey = account.toLowerCase();
      print('account: ${account.toLowerCase()}');
    }
    //_pubKey = await WalletConnect.loginUsingMetamask(context);

    print('pubkey: $_pubKey');

    await _generateNodeAddr();
    await _saveProfileData();
    if (metaResult) {
      bool? reCheck = await registerUser(contract, widget.user);

      print('object: ${widget.user.pubKey}');
      Navigator.pop(context);

      if (reCheck == true) {
        showRegistrationCompletePopup(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.grey,
          content: Text('Network Error'),
          duration: Duration(seconds: 1),
        ));
      }
    }
  }

  _openMetaMaskApp() async {
    final urlScheme = 'metamask://'; // MetaMask의 URL 스키마

    if (await canLaunch(urlScheme)) {
      // MetaMask 앱이 설치되어 있는 경우
      //await launch(urlScheme);
      signupWithMetamask();
    } else {
      // MetaMask 앱이 설치되어 있지 않은 경우, Play 스토어(Android) 또는 앱 스토어(iOS)로 이동
      _launchAppStore();
    }
  }

  _launchAppStore() async {
    final url =
        'https://play.google.com/store/apps/details?id=io.metamask'; // Play 스토어 URL
    if (Theme.of(context).platform == TargetPlatform.android) {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      // iOS에서 앱 스토어로 이동
      final iosUrl =
          'https://apps.apple.com/us/app/metamask/id1438144202'; // MetaMask iOS 앱의 앱 스토어 페이지 URL
      if (await canLaunch(iosUrl)) {
        await launch(iosUrl);
      } else {
        throw 'Could not launch $iosUrl';
      }
    }
  }

  Future<String> uploadFileToIPFS(File file, String token) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://ipfs.infura.io:5001/api/v0/add'),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
      ),
    );

    request.headers['Authorization'] = 'Basic $token';

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();
    var jsonResponse = json.decode(responseBody);

    if (jsonResponse.containsKey('Hash')) {
      print('all ${jsonResponse.toString()}');
      return jsonResponse['Hash'];
    } else {
      throw Exception('Failed to upload file to IPFS');
    }
  }

  Future<void> _saveProfileData() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file =
        File('${directory.path}/profile_data.json');

    final base64ImageData = base64Encode(_imageBytes);

    final data = {
      'userId': widget.user.id,
      'username': widget.user.name,
      'stateMessage': widget.user.status,
      'imageData': base64ImageData, // Base64로 인코딩된 이미지 데이터를 JSON에 포함
      'nodeAddress': widget.user.nodeAddr,
      'publicKey': widget.user.pubKey
    };

    final jsonString = json.encode(data);
    await file.writeAsString(jsonString);

    String credentials =
        "2ONnXhK5E0OyIEBTFsaZVRB5Agj:bba5e99a4c2228f58f06bd70af022106";
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(credentials);

    profileHash = await uploadFileToIPFS(file, encoded);
    widget.user.profileHash = profileHash;
    metaResult = true;

    print('hash $profileHash');
    print('Data saved to ${file.path}');
  }

  void showRegistrationCompletePopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32)),
          ),
          title: const Text(
            '회원가입 완료',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Container(
            height: 230,
            child: Column(
              children: <Widget>[
                Expanded(
                  // Expanded 위젯 추가
                  child: Image.asset(
                    'assets/complete.png',
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                const Text('회원가입이 성공적으로 완료되었습니다.'),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to\nBlockchain Messenger!',
                  style: TextStyle(fontSize: 25, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            RoundedButton(
              text: "확인",
              color: loginBackground,
              press: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WelcomePage()));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        body: ListView(
            //color: Colors.white,
            children: [
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  color: buttonColor2,
                  height: size.height * 0.05,
                ),
                Container(
                  child: CustomPaint(
                    child: Container(),
                    painter: HeaderCurvedContainer(),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 45,
                      letterSpacing: 1.5,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.0),
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.width / 2,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 5),
                        shape: BoxShape.circle,
                        color: Colors.white,
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: _image != null
                              ? _image!
                              : AssetImage('assets/profile.png'),
                        ),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: buttonColor,
                      child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          _getImage();
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  height: size.height * 0.35,
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        height: size.height * 0.05,
                      ),
                      RoundedTextField(
                        onChanged: (value) {
                          username = value;
                          widget.user.name = username;
                        },
                        hintColor: Colors.white,
                        color: buttonColor,
                        hintText: "Username",
                      ),
                      RoundedTextField(
                        onChanged: (value) {
                          setState(() {
                            stateMessage = value;
                            widget.user.status = stateMessage;
                          });
                        },
                        hintColor: Colors.white,
                        color: buttonColor,
                        hintText: "State message",
                      ),
                      RoundedButton(
                        text: 'SIGN UP',
                        press: () async {
                          if (username.isNotEmpty) {
                            await _openMetaMaskApp();
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              backgroundColor: Colors.grey,
                              content: Text('Please enter all information'),
                              duration: Duration(seconds: 1),
                            ));
                          }
                        },
                        textColor: Colors.black,
                        color: buttonColor2,
                      ),
                    ],
                  ),
                ),
                Container(
                    color: Colors.white,
                    child: AlreadyHaveBlockchainCheck(
                      press: () {},
                    ))
              ],
            ),
          )
        ]));
  }
}

class HeaderCurvedContainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = buttonColor2;
    Path path = Path()
      ..relativeLineTo(0, 150)
      ..quadraticBezierTo(size.width / 2, 225, size.width, 150)
      ..relativeLineTo(0, -150)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
