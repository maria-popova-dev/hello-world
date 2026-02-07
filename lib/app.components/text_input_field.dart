import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {

  final String label;
  final TextEditingController textEditingController;
  final TextInputType textInputType;
  final bool obscureText;

  const TextInputField({super.key,
    required this.label,
    required this.textEditingController,
    required this.textInputType,
    this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    return  TextField(
          controller: textEditingController,
          keyboardType: textInputType,
          obscureText: obscureText,
          decoration: InputDecoration(
          border: const OutlineInputBorder(),
          label: Text (label),
      )
    );
  }
}
