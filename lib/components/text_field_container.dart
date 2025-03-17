import 'package:flutter/material.dart';

class TextFieldContainer extends StatelessWidget {

  final Widget child;
  final Color color;
  const TextFieldContainer({
    required this.color,
    Key? key,
    required this.child
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      width: size.width * 0.8,
      height: size.height * 0.08,
      decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(30)),
      child: child,
    );
  }
}