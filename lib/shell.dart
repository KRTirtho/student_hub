import 'package:student_hub/collections/env.dart';
import 'package:student_hub/collections/logo.dart';
import 'package:student_hub/components/image/universal_image.dart';
import 'package:student_hub/components/scaffold/adaptive_scaffold.dart';
import 'package:student_hub/models/post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final routes = {
  {
    "label": "Feed",
    "path": "/?type=${PostType.question.name},${PostType.informative.name}",
    "icon": Icons.feed_outlined
  },
  {
    "label": "Announces",
    "path": "/${PostType.announcement.name}",
    "icon": Icons.campaign_outlined
  },
  {
    "label": "Library",
    "path": "/library",
    "icon": Icons.library_books_outlined
  },
  {
    "label": "Profile",
    "path": "/profile/authenticated",
    "icon": Icons.person_outline_rounded
  }
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

    return AdaptiveScaffold(
      destinations: [
        for (final route in routes)
          NavigationDestination(
            label: route["label"] as String,
            icon: Icon(route["icon"] as IconData),
          ),
      ],
      selectedIndex: selectedIndex.value,
      onSelectedIndexChange: (index) {
        selectedIndex.value = index;
        final path = routes.elementAt(index)["path"] as String;
        GoRouter.of(context).go(path);
      },
      useDrawer: false,
      internalAnimations: false,
      leadingExtendedNavRail: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Gap(16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 40),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: UniversalImage(path: getLogoPath(context)),
            ),
          ),
          const Gap(8),
          const Text(
            Env.applicationDisplayName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      leadingUnextendedNavRail: Container(
        width: 60,
        padding: const EdgeInsets.all(8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: UniversalImage(path: getLogoPath(context)),
        ),
      ),
      body: (context) => child,
    );
  }
}
