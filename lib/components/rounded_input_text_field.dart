import 'package:flutter/material.dart';
import 'package:blockchain_messenger/components/text_field_container.dart';


class RoundedTextField extends StatelessWidget {
  final String hintText;
  final Color color, hintColor;
  final ValueChanged<String> onChanged;


  const RoundedTextField({
    Key? key,
    required this.hintText, required this.color, required this.hintColor, required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  TextFieldContainer(
      color: color,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: hintColor),
            border: InputBorder.none
        ),
      ),);
  }
}