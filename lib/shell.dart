import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:eusc_freaks/models/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final routes = {
  {
    "label": "Feed",
    "path": "/?type=${PostType.question.name},${PostType.informative.name}",
    "icon": Icons.feed_outlined
  },
  {"label": "Search", "path": "/search", "icon": Icons.search_outlined},
  {
    "label": "Announces",
    "path": "/?type=${PostType.announcement.name}",
    "icon": Icons.campaign_outlined
  },
  {"label": "Profile", "path": "/profile", "icon": Icons.person_outline_rounded}
};

class Shell extends HookConsumerWidget {
  final Widget child;
  const Shell({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, ref) {
    final selectedIndex = useState(0);

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
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex.value,
        destinations: [
          for (final route in routes)
            NavigationDestination(
              label: route["label"] as String,
              icon: Icon(route["icon"] as IconData),
            ),
        ],
        onDestinationSelected: (index) {
          selectedIndex.value = index;
          final path = routes.elementAt(index)["path"] as String;
          GoRouter.of(context).go(path);
        },
      ),
      body: child,
    );
  }
}
