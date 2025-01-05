import 'package:flutter/material.dart';

WidgetStateProperty<T> materialMatch<T>({
  required T all,
  T? hovered,
  T? pressed,
}) {
  return WidgetStateProperty.resolveWith(
    (states) {
      if (hovered != null && states.contains(WidgetState.hovered)) {
        return hovered;
      } else if (pressed != null && states.contains(WidgetState.pressed)) {
        return pressed;
      }
      return all;
    },
  );
}
