import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

T useBrightnessValue<T>(T light, T dark) {
  final context = useContext();
  return Theme.of(context).brightness == Brightness.light ? light : dark;
}
