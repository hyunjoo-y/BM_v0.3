import 'package:flutter/material.dart';

class AlreadyHaveBlockchainCheck extends StatelessWidget {
  final Function() press;

  const AlreadyHaveBlockchainCheck(
      {Key? key, required this.press})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            "Do you have an Blockchain Account? ",
            style: TextStyle(color: Colors.grey),
          ),
          GestureDetector(
            onTap: press,
            child: const Text(
              "Import your Account!",
              style:
              TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height),
      )
    ]);
  }
}
