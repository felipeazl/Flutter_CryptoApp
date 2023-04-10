// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  final IconData? leadingIcon;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onPressed;
  final List<Widget>? action;

  const CustomAppBar(
      {Key? key,
      required this.title,
      this.leadingIcon,
      this.backgroundColor,
      this.textColor,
      this.onPressed,
      this.action})
      : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      elevation: 0,
      actions: action,
      backgroundColor: backgroundColor,
      leading: IconButton(
        icon: Icon(
          leadingIcon,
          color: textColor,
          size: 28,
        ),
        onPressed: onPressed,
      ),
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
