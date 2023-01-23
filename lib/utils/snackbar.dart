import 'package:flutter/material.dart';

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackbar(
  BuildContext context,
  String message, {
  bool isDismissible = true,
  Color? backgroundColor,
  SnackBarAction? customAction,
}) {
  assert(
    !(customAction != null && isDismissible),
    "Can't have a custom action and be dismissible",
  );
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
      backgroundColor: backgroundColor,
      width: 350,
      action: isDismissible
          ? SnackBarAction(
              label: 'Dismiss',
              textColor: Theme.of(context).backgroundColor,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            )
          : customAction,
    ),
  );
}
