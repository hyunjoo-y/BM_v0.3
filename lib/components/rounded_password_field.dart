import 'package:flutter/material.dart';
import 'package:blockchain_messenger/components/text_field_container.dart';

class RoundedPasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final Color color,hintColor,iconColor;
  const RoundedPasswordField({
    Key? key,
    required this.onChanged, required this.color, required this.hintColor, required this.iconColor
  }) : super(key: key);

  @override
  _RoundedPasswordFieldState createState() => _RoundedPasswordFieldState();
}

class _RoundedPasswordFieldState extends State<RoundedPasswordField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
        color: widget.color,
        child: TextField(
            onChanged: widget.onChanged,
            obscureText: _isObscure,
            decoration: InputDecoration(
              icon: Icon(Icons.lock, color: widget.iconColor),
              hintText: 'Enter Your Private Key',
              hintStyle: TextStyle(color: widget.hintColor),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_off : Icons.visibility,
                  color: widget.iconColor,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure;
                  });
                },
              ),
            )
        ));
  }
}
