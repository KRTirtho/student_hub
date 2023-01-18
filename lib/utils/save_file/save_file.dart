import 'package:eusc_freaks/utils/save_file/save_file_stub.dart'
    if (dart.library.html) 'package:eusc_freaks/utils/save_file/save_file_web.dart';
import 'package:flutter/foundation.dart';

Future<void> saveFile(
  Uint8List bytes,
  String fileName,
) {
  return saveFileWeb(bytes, fileName);
}
