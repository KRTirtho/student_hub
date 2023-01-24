import 'package:flutter/material.dart';

String getLogoPath(BuildContext context) {
  if (Theme.of(context).brightness == Brightness.light) {
    return 'assets/logo_light.png';
  }
  return 'assets/logo.png';
}
