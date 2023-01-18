import 'dart:js' as js;
import 'dart:html' as html;

import 'package:flutter/foundation.dart';

Future<void> saveFileWeb(Uint8List bytes, String fileName) async {
  await Future.value(
    js.context.callMethod(
      "webSaveAs",
      [
        html.Blob([bytes]),
        fileName,
      ],
    ),
  );
}
