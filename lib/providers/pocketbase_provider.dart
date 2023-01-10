import 'package:eusc_freaks/collections/env.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod/riverpod.dart';

final pocketbaseProvider = Provider(
  (ref) => PocketBase(Env.pocketbaseUrl),
);
