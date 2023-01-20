import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RooAppBar extends AppBar {
  RooAppBar({
    List<Widget>? actions,
    super.key,
  }) : super(
          primary: true,
          title: const Text("Eusc Freaks"),
          centerTitle: false,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: const UniversalImage(path: "assets/logo.png"),
            ),
          ),
          actions: actions ??
              [
                Builder(builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.search_outlined),
                    onPressed: () {
                      GoRouter.of(context).push("/search");
                    },
                  );
                }),
                Builder(builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () {
                      GoRouter.of(context).push("/settings");
                    },
                  );
                }),
              ],
        );
}
