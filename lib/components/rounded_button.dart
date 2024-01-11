import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final Color color;
  final String buttonTitle;
  final VoidCallback onPressed;

  const RoundedButton({
    required this.color,
    required this.onPressed,
    required this.buttonTitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(30.0),
        child: MaterialButton(
          onPressed: onPressed,
          minWidth: 200.0,
          height: 42.0,
          child: Text(
            buttonTitle,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
