import 'package:student_hub/utils/save_file/save_file_stub.dart'
    if (dart.library.html) 'package:app/utils/save_file/save_file_web.dart';
import 'package:flutter/foundation.dart';

Future<void> saveFile(
  Uint8List bytes,
  String fileName,
) {
  return saveFileWeb(bytes, fileName);
}
