import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostsPage extends HookConsumerWidget {
  const PostsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      appBar: AppBar(
        primary: true,
        title: const Text("Eusc Freaks"),
        centerTitle: false,
        leading: const UniversalImage(path: "assets/logo.jpg", height: 40),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              GoRouter.of(context).push("/settings");
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).push("/new");
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
