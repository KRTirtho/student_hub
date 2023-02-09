import 'package:student_hub/collections/sstorage.dart';
import 'package:student_hub/models/user.dart';
import 'package:student_hub/collections/pocketbase.dart';
import 'package:student_hub/utils/platform.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:riverpod/riverpod.dart';

class AuthenticationNotifier extends StateNotifier<User?> {
  Ref ref;
  AuthenticationNotifier(
    this.ref,
  ) : super(null) {
    secureStorage.read(key: "token").then((token) async {
      if (token == null || token.isEmpty) {
        if (kIsMobile) FlutterNativeSplash.remove();
        return;
      }
      pb.authStore.save(token, null);
      final res = await pb.collection("users").authRefresh();
      if (res.record == null) {
        if (kIsMobile) FlutterNativeSplash.remove();
        return;
      }
      state = User.fromRecord(res.record!);
    });
    pb.authStore.onChange.listen((event) async {
      if (event.model != null && state == null) {
        state = User.fromRecord(event.model);
      }
      if (event.token.isNotEmpty) {
        await secureStorage.write(key: "token", value: event.token);
      }
    });
  }

  bool get isLoggedIn => state != null;

  Future<void> refetch() async {
    if (state == null) return;
    final res = await pb.collection("users").authRefresh();
    if (res.record == null) return;
    state = User.fromRecord(res.record!);
  }

  Future<User?> login(String email, String password) async {
    final res = await pb.collection('users').authWithPassword(email, password);

    if (res.record != null) {
      state = User.fromRecord(res.record!);
      return state;
    }
    return null;
  }

  Future<User?> signup({
    required String name,
    required String username,
    required String password,
    required String passwordConfirm,
    required String email,
    required SessionObject? session,
    required bool isMaster,
  }) async {
    await pb.collection("users").create(body: {
      "username": username,
      "email": email,
      "password": password,
      "passwordConfirm": passwordConfirm,
      "emailVisibility": true,
      "verified": false,
      "name": name,
      "sessions": session?.toString() ?? "",
      "isMaster": isMaster,
    });
    await pb.collection("users").requestVerification(email);

    final loginRes =
        await pb.collection('users').authWithPassword(email, password);
    if (loginRes.record != null) {
      state = User.fromRecord(loginRes.record!);
    }

    return await login(email, password);
  }

  Future<void> confirm(String token) async {
    await pb.collection("users").confirmVerification(token);
  }

  void logout() async {
    pb.authStore.clear();
    await secureStorage.delete(key: "token");
    state = null;
  }
}

final authenticationProvider =
    StateNotifierProvider<AuthenticationNotifier, User?>(
  (ref) => AuthenticationNotifier(ref),
);
