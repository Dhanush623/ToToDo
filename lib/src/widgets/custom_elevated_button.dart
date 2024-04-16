import 'package:flutter/material.dart';

customElevatedButton(String title, Function handle) {
  return ElevatedButton(
    onPressed: () {
      handle();
    },
    child: Text(title),
  );
}
