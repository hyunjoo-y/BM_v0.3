import 'package:blockchain_messenger/components/already_have_account_check.dart';
import 'package:blockchain_messenger/components/constant.dart';
import 'package:blockchain_messenger/components/importLoginAccount.dart';
import 'package:blockchain_messenger/components/rounded_button.dart';
import 'package:blockchain_messenger/components/rounded_input_field.dart';
import 'package:blockchain_messenger/components/rounded_password_field.dart';
import 'package:blockchain_messenger/contracts/messenger_contract.dart';
import 'package:blockchain_messenger/models/contract_model.dart';
import 'package:blockchain_messenger/models/metamask_model.dart';
import 'package:blockchain_messenger/models/user_model.dart';
import 'package:blockchain_messenger/screens/home_page.dart';
import 'package:blockchain_messenger/screens/profile_page.dart';
import 'package:blockchain_messenger/screens/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final String contractAddress = "0x89040b700913F8B3994875825fd23B7A63A2e7f9";
  final String blockchainUrl = "http://115.85.181.212:30011";
  final String priv =
      "778f4905fcee27222ef12e05885d5edf740a5bf2881e4340c9379a4cf99c711c";

  late Client httpClient;
  late Web3Client ethClient;
  late Contracts contract;
  var _pubKey = '';

  String inputUserId = '';
  String inputPwd = '';

  User user = User(
    id: '',
    nodeAddr: '',
    pubKey: '',
    name: '',
    avatar: [],
    status: '',
    profileHash: '',
  );

  @override
  void initState() {
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

  Future<bool> inputPrivlogin(String _pwd) async {
    var pubKey = convertPrivateKeyToPublicKey(
        '637a58cdb0eee82b2d49ab5eb8a4b6fadf16f10c36b4cf521786e09b4325dbc5');
    print('pubKey: $pubKey');
    bool? login = await getUserLogin(contract, inputUserId, pubKey);
    return login;
  }

  String convertPrivateKeyToPublicKey(String _pwd) {
    final privateKeyObject = EthPrivateKey.fromHex(
        _pwd); // Create a private key object from the provided private key string
    final address = privateKeyObject
        .address; // Get the public address associated with the private key
    return address.hex;
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        backgroundColor: buttonColor,
        body: SingleChildScrollView(
            child: Column(children: <Widget>[
          SizedBox(
            height: size.height * 0.2,
          ),
          const Text(
            'Login',
            style: TextStyle(
                fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(
            height: size.height * 0.02,
          ),
          SizedBox(
            height: size.height * 0.04,
            child: const Text(
              'Welcome to Blockchain Messenger',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                  color: Colors.white),
            ),
          ),
          SizedBox(
            height: size.height * 0.02,
          ),
          Container(
            //constraints: BoxConstraints(
            //  maxHeight: MediaQuery.of(context).size.height),
            alignment: Alignment.topLeft,
            padding: EdgeInsets.only(top: 100, left: 40, right: 40),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            child: Column(
              children: <Widget>[
                RoundedInputField(
                  iconColor: buttonColor,
                  hintColor: Colors.grey,
                  color: buttonColor2,
                  hintText: "Enter Your ID",
                  onChanged: (value) {
                    setState(() {
                      inputUserId = value;
                    });
                  },
                ),
                SizedBox(height: size.height * 0.03),
                RoundedPasswordField(
                  hintColor: Colors.grey,
                  color: buttonColor2,
                  onChanged: (value) {
                    setState(() {
                      inputPwd = value;
                    });
                  },
                  iconColor: buttonColor,
                ),
                SizedBox(height: size.height * 0.05),
                RoundedButton(
                  text: 'LOGIN',
                  press: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                    // // real login
                    // if (inputUserId.isNotEmpty) {
                    //   if (inputPwd.isNotEmpty) {
                    //     bool? checkUser =
                    //         await checkUserExists(contract, inputUserId);
                    //     if (!checkUser) {
                    //       ScaffoldMessenger.of(context)
                    //           .showSnackBar(const SnackBar(
                    //         backgroundColor: Colors.grey,
                    //         content: Text('Check Your ID'),
                    //         duration: Duration(seconds: 1),
                    //       ));
                    //     } else {
                    //       var loginResult = await inputPrivlogin(inputPwd);
                    //       if (loginResult) {
                    //         // ignore: use_build_context_synchronously
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (context) => HomePage()),
                    //         );
                    //       } else {
                    //         ScaffoldMessenger.of(context)
                    //             .showSnackBar(const SnackBar(
                    //           backgroundColor: Colors.grey,
                    //           content: Text('Check Your Private Key'),
                    //           duration: Duration(seconds: 1),
                    //         ));
                    //       }
                    //     }
                    //   } else {
                    //     ScaffoldMessenger.of(context)
                    //         .showSnackBar(const SnackBar(
                    //       backgroundColor: Colors.grey,
                    //       content: Text(
                    //           'Enter the private Key or Import your blockchain Wallet'),
                    //       duration: Duration(seconds: 1),
                    //     ));
                    //   }
                    // } else {
                    //   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    //     backgroundColor: Colors.grey,
                    //     content: Text('Enter Your ID'),
                    //     duration: Duration(seconds: 2),
                    //   ));
                    // }

                    user.id = inputUserId;
                  },
                ),
                Container(
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ImportLoginAccount(
                        press: () async {
                          if (inputUserId.isEmpty) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              backgroundColor: Colors.grey,
                              content: Text('Enter Your ID'),
                              duration: Duration(seconds: 2),
                            ));
                          } else {
                            _pubKey =
                                await WalletConnect.loginUsingMetamask(context);
                            if (_pubKey.toLowerCase() == '') {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                backgroundColor: Colors.grey,
                                content: Text('Check Your Blockchain Wallet'),
                                duration: Duration(seconds: 1),
                              ));
                            } else {

                            // ignore: use_build_context_synchronously
                            showLoaderDialog(context);
                              bool? login = await getUserLogin(
                                  contract, inputUserId, _pubKey.toLowerCase());
                            // ignore: use_build_context_synchronously
                            Navigator.pop(context);
                              if (login) {
                                // ignore: use_build_context_synchronously
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()),
                                );
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  backgroundColor: Colors.grey,
                                  content: Text('Check Your Blockchain Wallet'),
                                  duration: Duration(seconds: 1),
                                ));
                              }
                            }
                          }
                        },
                      ),
                      Text(
                        '자동로그인',
                        style: GoogleFonts.abel(
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                AlreadyHaveAccountCheck(
                  press: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                ),
                SizedBox(height: MediaQuery.of(context).size.height),
              ],
            ),
          ),
        ])));
  }
}
