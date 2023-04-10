import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final double paddingText;
  final double? fontSizeText;
  final double? iconSize;
  final IconData? icon;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.title,
    required this.paddingText,
    this.fontSizeText,
    this.iconSize,
    this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
          ),
          Padding(
            padding: EdgeInsets.all(paddingText),
            child: Text(
              title,
              style: TextStyle(fontSize: fontSizeText),
            ),
          )
        ],
      ),
    );
  }
}
