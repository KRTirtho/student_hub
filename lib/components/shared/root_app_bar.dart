import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RooAppBar extends AppBar {
  RooAppBar({super.key})
      : super(
          primary: true,
          title: const Text("Eusc Freaks"),
          centerTitle: false,
          leading: const UniversalImage(path: "assets/logo.png", height: 40),
          actions: [
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
