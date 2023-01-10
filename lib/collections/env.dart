import 'package:envied/envied.dart';
import 'package:eusc_freaks/utils/platform.dart';
import 'package:flutter/foundation.dart';

part 'env.g.dart';

final _envInstance = Env._();

class Env {
  late final String pocketbaseUrl;
  late final bool verifyEmail;

  factory Env() => _envInstance;

  Env._() {
    if (kReleaseMode) {
      pocketbaseUrl = _ProdEnv.pocketbaseUrl;
      verifyEmail = _ProdEnv.verifyEmail;
    } else {
      pocketbaseUrl =
          kIsMobile ? _ProdEnv.pocketbaseUrl : _DevEnv.pocketbaseUrl;
      verifyEmail = _DevEnv.verifyEmail;
    }
  }
}

@Envied(
  name: "EnvDev",
  obfuscate: true,
  path: "dev.env",
)
class _DevEnv {
  @EnviedField(varName: "POCKETBASE_URL")
  static String pocketbaseUrl = _EnvDev.pocketbaseUrl;

  @EnviedField(varName: "VERIFY_EMAIL")
  static bool verifyEmail = _EnvDev.verifyEmail;
}

@Envied(
  name: "EnvProd",
  obfuscate: true,
  path: "prod.env",
)
class _ProdEnv {
  @EnviedField(varName: "POCKETBASE_URL")
  static String pocketbaseUrl = _EnvProd.pocketbaseUrl;

  @EnviedField(varName: "VERIFY_EMAIL")
  static bool verifyEmail = _EnvProd.verifyEmail;
}
