import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackbar(
  BuildContext context,
  String message, {
  bool isDismissible = true,
  Color? backgroundColor,
}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
      backgroundColor: backgroundColor,
      action: isDismissible
          ? SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            )
          : null,
    ),
  );
}
