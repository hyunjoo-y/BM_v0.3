// ignore_for_file: use_build_context_synchronously

import 'package:blockchain_messenger/contracts/messenger_contract.dart';
import 'package:blockchain_messenger/models/contract_model.dart';
import 'package:blockchain_messenger/models/user_model.dart';
import 'package:flutter/material.dart';

// components
import 'package:blockchain_messenger/components/constant.dart';
import 'package:blockchain_messenger/components/rounded_input_field.dart';
import 'package:blockchain_messenger/components/rounded_button.dart';
import 'package:blockchain_messenger/components/already_have_account_check.dart';

// screens
import 'package:blockchain_messenger/screens/profile_page.dart';
import 'package:blockchain_messenger/screens/signin_page.dart';

import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Body(),
        ));
  }
}

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  State<Body> createState() => _BodyState();
}

class _BodyState extends State<Body> {
  late TextEditingController id;
  late TextEditingController privKey;

  late Client httpClient;
  late Web3Client ethClient;

  final String contractAddress = "0x89040b700913F8B3994875825fd23B7A63A2e7f9";
  final String blockchainUrl = "http://115.85.181.212:30011";
  final String priv =
      "778f4905fcee27222ef12e05885d5edf740a5bf2881e4340c9379a4cf99c711c";

  User user = User(id: '', nodeAddr: '', pubKey: '', name: '', avatar: [], status: '', profileHash: '');
  late Contracts contract;

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

  snackBar({String? label}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label!),
            CircularProgressIndicator(
              color: Colors.white,
            )
          ],
        ),
        duration: Duration(days: 1),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _title() {
    return const Align(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Blockchain ',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              Text(
                'Messenger',
                style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 36), // 오른쪽 마진 추가
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'More powerful and safer',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    String userId = "";

    return Column(
      children: <Widget>[
        Container(
            height: size.height * 0.3,
            margin: const EdgeInsets.only(top: 100),
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/logo.png'),
                    fit: BoxFit.contain))),
        _title(),
        Container(
            //constraints: BoxConstraints(
            //  maxHeight: MediaQuery.of(context).size.height),
            alignment: Alignment.topLeft,
            margin: const EdgeInsets.only(top: 20),
            padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0))),
            child: Container(
              color: Colors.white,
              height: size.height * 0.35,
              child: Column(
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    height: size.height * 0.03,
                  ),
                  RoundedInputField(
                    iconColor: buttonColor2,
                    hintColor: Colors.white,
                    color: buttonColor,
                    hintText: "Enter the ID you want to use",
                    onChanged: (value) {
                      userId = value;
                    },
                  ),
                  Container(
                    color: Colors.white,
                    height: size.height * 0.03,
                  ),
                  RoundedButton(
                    text: 'Next',
                    press: () async {
                      if (userId.isNotEmpty) {
                        var result = await checkUserExists(contract, userId);

                        if (result) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            backgroundColor: Colors.grey,
                            content: Text('The account already exists'),
                            duration: Duration(seconds: 1),
                          ));
                        } else {
                          user.id = userId;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                user: user,
                              ),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          backgroundColor: Colors.grey,
                          content: Text('Please Enter the User ID'),
                          duration: Duration(seconds: 1),
                        ));
                      }
                    },
                    textColor: Colors.black,
                    color: buttonColor2,
                  ),
                  Container(
                    color: Colors.white,
                    height: size.height * 0.02,
                  ),
                  Container(
                    color: Colors.white,
                    child: AlreadyHaveAccountCheck(
                      login: false,
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
