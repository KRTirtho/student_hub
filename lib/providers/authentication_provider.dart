import 'package:eusc_freaks/collections/sstorage.dart';
import 'package:eusc_freaks/models/user.dart';
import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:riverpod/riverpod.dart';

class AuthenticationNotifier extends StateNotifier<User?> {
  Ref ref;
  AuthenticationNotifier(
    this.ref,
  ) : super(null) {
    secureStorage.read(key: "token").then((token) async {
      if (token == null) return;
      pb.authStore.save(token, null);
      final res = await pb.collection("users").authRefresh();
      if (res.record == null) return;
      state = User.fromRecord(res.record!);
    });
    pb.authStore.onChange.listen((event) async {
      if (event.model != null && state == null) {
        state = User.fromRecord(event.model["data"]);
      }
      await secureStorage.write(key: "token", value: event.token);
    });
  }

  bool get isLoggedIn => state != null;

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
  }) async {
    final res = await pb.collection("users").create(body: {
      "username": username,
      "email": email,
      "password": password,
      "passwordConfirm": passwordConfirm,
      "emailVisibility": true,
      "verified": false,
      "name": name,
    });
    state = User.fromJson(res.data);
    await pb.collection("users").requestVerification(email);
    return state;
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
