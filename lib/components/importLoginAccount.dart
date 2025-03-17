import 'package:flutter/material.dart';

class ImportLoginAccount extends StatelessWidget {
  final Function() press;

  const ImportLoginAccount(
      {Key? key, required this.press})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            "Login with metamask?   ",
            style: TextStyle(color: Colors.grey),
          ),
          GestureDetector(
            onTap: press,
            child: Text(
              "Import   ",
              style:
              TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),

    ]);
  }
}
