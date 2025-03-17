import 'package:flutter/material.dart';
import 'package:blockchain_messenger/components/text_field_container.dart';


class ProfileInputField extends StatelessWidget {
  final String hintText;
  final Color color, hintColor;
  final TextEditingController controller;

  const ProfileInputField({
    Key? key,
    required this.hintText,
    required this.controller, required this.color, required this.hintColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  TextFieldContainer(
      color: color,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: hintColor),
            border: InputBorder.none
        ),
      ),);
  }
}