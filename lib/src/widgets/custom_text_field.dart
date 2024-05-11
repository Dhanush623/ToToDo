import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget customTextInput(
  TextEditingController controller,
  List<TextInputFormatter>? inputFormatter,
  TextInputType? textInputType,
  Function handle,
  String? label,
  String hint,
  bool? enabled,
) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      label: label != null ? Text(label) : null,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
    ),
    enabled: enabled,
    keyboardType: textInputType,
    inputFormatters: inputFormatter,
    onChanged: (value) {
      handle(value);
    },
  );
}
