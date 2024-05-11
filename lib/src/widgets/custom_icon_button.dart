import 'package:flutter/material.dart';

customIconButton(IconData icon, String? tooltip, Function handle) {
  return IconButton(
    icon: Icon(icon),
    onPressed: () => {handle()},
    tooltip: tooltip,
  );
}
