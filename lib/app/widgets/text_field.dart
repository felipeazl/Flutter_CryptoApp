// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? prefixIcon;
  final String? suffix;
  final TextInputType? inputType;
  final List<TextInputFormatter>? inputFormatter;
  final String? Function(String?)? validators;
  final void Function(String)? onChanged;
  final bool obscure;
  final double? fontSize;
  final Widget? suffixIcon;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.label,
    this.prefixIcon,
    this.suffix = "",
    this.inputType,
    this.inputFormatter,
    this.validators,
    this.onChanged,
    this.obscure = false,
    this.fontSize = 22,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        fontSize: fontSize,
      ),
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        label: Text(label),
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        suffix: Text(
          suffix!,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
      ),
      keyboardType: inputType,
      inputFormatters: inputFormatter,
      validator: validators,
      onChanged: onChanged,
      obscureText: obscure,
    );
  }
}
