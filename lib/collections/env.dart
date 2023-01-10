import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied()
class Env {
  @EnviedField(varName: "POCKETBASE_URL")
  static const String pocketbaseUrl = _Env.pocketbaseUrl;

  @EnviedField(varName: "VERIFY_EMAIL")
  static const bool verifyEmail = _Env.verifyEmail;
}
