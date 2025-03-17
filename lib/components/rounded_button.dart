import 'package:flutter/material.dart';
import 'package:blockchain_messenger/components/constant.dart';

class RoundedButton extends StatelessWidget {
  final String text;
  final Function() press;
  final Color color, textColor;

  const RoundedButton({
    Key? key,
    required this.text,
    required this.press,
    this.color = buttonColor,
    this.textColor = Colors.white
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      width: size.width *0.8,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
            backgroundColor: color,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(40)))
        ),
        onPressed: press,
        child: Text(text,style: TextStyle(color: textColor,fontSize: 15),),
      ),
    );
  }
}