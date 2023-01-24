import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:eusc_freaks/queries/notifications.dart';
import 'package:fl_query/fl_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RooAppBar extends AppBar {
  RooAppBar({
    List<Widget>? actions,
    super.key,
  }) : super(
          primary: true,
          title: SlotLayout(
            config: {
              Breakpoints.standard: SlotLayout.from(
                key: const Key("app_title"),
                builder: (context) {
                  return const Text(
                    "EUSC Hub",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
              Breakpoints.medium: SlotLayout.from(
                key: const Key("app_title"),
                builder: (context) {
                  return const SizedBox.shrink();
                },
              ),
              Breakpoints.large: SlotLayout.from(
                key: const Key("app_title"),
                builder: (context) {
                  return const SizedBox.shrink();
                },
              ),
            },
          ),
          centerTitle: false,
          leading: SlotLayout(
            config: {
              Breakpoints.standard: SlotLayout.from(
                key: const Key("logo"),
                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: const UniversalImage(path: "assets/logo.png"),
                    ),
                  );
                },
              ),
              Breakpoints.medium: SlotLayout.from(
                key: const Key("logo"),
                builder: (context) {
                  return const SizedBox.shrink();
                },
              ),
              Breakpoints.large: SlotLayout.from(
                key: const Key("logo"),
                builder: (context) {
                  return const SizedBox.shrink();
                },
              ),
            },
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
                HookConsumer(
                  builder: (context, ref, _) => InfiniteQueryBuilder(
                      job: notificationsQueryJob,
                      externalData: ref.watch(authenticationProvider)?.id,
                      builder: (context, notifications) {
                        final unreadNotifications = notifications.pages
                            .expand((element) => element?.items.toList() ?? [])
                            .where((element) => !element.viewed)
                            .toList()
                            .length;
                        return IconButton(
                          onPressed: () {
                            GoRouter.of(context).push("/notifications");
                          },
                          icon: Badge(
                            showBadge: unreadNotifications > 0,
                            badgeContent: Text(
                              unreadNotifications.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                            child: const Icon(Icons.notifications_outlined),
                          ),
                        );
                      }),
                ),
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
