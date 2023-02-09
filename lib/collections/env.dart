import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class Env {
  static const applicationDisplayName = "EUSC hub";
  static final String pocketbaseUrl = dotenv.get(
    'POCKETBASE_URL',
    fallback: 'http://127.0.0.1:8090',
  );
  static final bool verifyEmail = dotenv.get(
        'VERIFY_EMAIL',
        fallback: 'false',
      ) ==
      'true';

  static configure() async {
    if (kReleaseMode) {
      await dotenv.load(fileName: "prod.env");
    } else {
      await dotenv.load(fileName: "dev.env");
    }
  }
}
