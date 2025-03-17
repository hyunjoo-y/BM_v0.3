import 'package:flutter/material.dart';
import 'package:blockchain_messenger/screens/welcome_body.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: WelcomeBody(),
    );
  }

}


