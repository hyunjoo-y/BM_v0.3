import 'package:blockchain_messenger/screens/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:blockchain_messenger/components/constant.dart';
import 'package:blockchain_messenger/components/background.dart';
import 'package:blockchain_messenger/components/rounded_button.dart';
import 'package:blockchain_messenger/screens/signin_page.dart';


class WelcomeBody extends StatelessWidget {
  const WelcomeBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Background(
        child: SingleChildScrollView(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: size.height * 0.2,
            ),
            Image.asset("assets/logo.png", height: size.height * 0.2),
            SizedBox(
              height: size.height * 0.08,
            ),
            SizedBox(
              height: size.height * 0.15,
            ),
            RoundedButton(
              text: "SIGN IN",
              press: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
            ),
            RoundedButton(
              text: "SIGN UP",
              press: () {
                Navigator.push(context,
                    //MaterialPageRoute(builder: (context) => GenerateAccountPage()));
                    //MaterialPageRoute(builder: (context) => ProfilePageEX()));
                    MaterialPageRoute(builder: (context) => SignUpPage()));
                    //MaterialPageRoute(builder: (context) => GenerateAccount()));
              },
              color: buttonColor2,
              textColor: Colors.black,
            ),
          ]),
    ));
  }
}
