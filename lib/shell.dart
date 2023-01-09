import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';

const routes = {
  {"label": "Feed", "path": "/", "icon": Icons.feed_outlined},
  {"label": "Search", "path": "/search", "icon": Icons.search_outlined},
  {"label": "Profile", "path": "/profile", "icon": Icons.person_outline_rounded}
};

class Shell extends HookWidget {
  final Widget child;
  const Shell({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(0);

    return Scaffold(
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
