import 'package:student_hub/collections/assets.gen.dart';
import 'package:flutter/material.dart';

String getLogoPath(BuildContext context) {
  if (Theme.of(context).brightness == Brightness.light) {
    return Assets.logoLight.path;
  }
  return Assets.logo.path;
}
