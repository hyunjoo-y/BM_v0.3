import 'package:flutter/material.dart';

class AlreadyHaveAccountCheck extends StatelessWidget {
  final bool login;
  final Function() press;

  const AlreadyHaveAccountCheck(
      {Key? key, this.login = true, required this.press})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            login ? "Don't have an Account? " : "Already have an Account? ",
            style: TextStyle(color: Colors.grey),
          ),
          GestureDetector(
            onTap: press,
            child: Text(
              login ? "Sign Up!" : "Sign In!",
              style:
              TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      
    ]);
  }
}
