import 'package:flutter/material.dart';
import 'package:blockchain_messenger/components/text_field_container.dart';


class RoundedInputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final Color iconColor, color, hintColor;
  final ValueChanged<String> onChanged;


  const RoundedInputField({
    Key? key,
    required this.hintText,
    this.icon = Icons.person,
    required this.onChanged, required this.color, required this.hintColor, required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  TextFieldContainer(
      color: color,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
            icon: Icon(icon, color: iconColor),
            hintText: hintText,
            hintStyle: TextStyle(color: hintColor),
            border: InputBorder.none
        ),
      ),);
  }
}