import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffix,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffix,
      ),
    );
  }
}
