import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

class LOLFile {
  final String name;
  final String? path;
  final Uint8List? bytes;
  final String type;

  LOLFile({
    required this.type,
    String? name,
    this.path,
    this.bytes,
  })  : assert(
          (name != null && bytes != null) || path != null,
          "Either name and bytes or path must be provided",
        ),
        name = name ?? basename(path!).split("?").first;

  factory LOLFile.fromPlatformFile(PlatformFile file, String type) => LOLFile(
        name: file.name,
        path: !kIsWeb ? file.path : null,
        bytes: file.bytes,
        type: type,
      );

  factory LOLFile.fromUri(Uri uri, String type) => LOLFile(
        name: basename(uri.path),
        path: uri.toString(),
        type: type,
      );

  PlatformFile toPlatformFile() => PlatformFile(
        name: name,
        path: path,
        bytes: bytes,
        size: bytes?.length ?? 0,
      );

  Uri toUri() => Uri.parse(path!);

  Future<MultipartFile> toMultipartFile(String field) async {
    if (bytes != null) {
      return MultipartFile.fromBytes(
        field,
        bytes!,
        filename: name,
        contentType: MediaType(type, extension(path ?? name).substring(1)),
      );
    } else {
      final file = await DefaultCacheManager().getSingleFile(path!);
      return MultipartFile.fromBytes(
        field,
        await file.readAsBytes(),
        filename: name,
        contentType: MediaType(type, extension(path!).substring(1)),
      );
    }
  }

  MediaType get mimeType =>
      MediaType(type, extension(path ?? name).substring(1));

  String get universalPath => path ?? base64Encode(bytes!);

  @override
  operator ==(Object other) =>
      identical(this, other) ||
      other is LOLFile &&
          other.name == name &&
          other.path == path &&
          other.bytes == bytes &&
          other.type == type;

  @override
  int get hashCode =>
      name.hashCode ^ path.hashCode ^ bytes.hashCode ^ type.hashCode;
}
