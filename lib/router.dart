import 'package:eusc_freaks/pages/posts/post.dart';
import 'package:eusc_freaks/pages/posts/post_new.dart';
import 'package:eusc_freaks/pages/posts/posts.dart';
import 'package:eusc_freaks/pages/profile/profile.dart';
import 'package:eusc_freaks/pages/settings/settings.dart';
import 'package:eusc_freaks/shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();
final routerConfig = GoRouter(
  initialLocation: '/',
  navigatorKey: navigatorKey,
  routes: [
    ShellRoute(
      navigatorKey: shellNavigatorKey,
      builder: (context, state, child) => Shell(child: child),
      routes: [
        GoRoute(
          path: '/',
          parentNavigatorKey: shellNavigatorKey,
          pageBuilder: (context, state) => const MaterialPage(
            child: PostsPage(),
          ),
          routes: [
            GoRoute(
              path: 'posts/:id',
              parentNavigatorKey: shellNavigatorKey,
              pageBuilder: (context, state) => const MaterialPage(
                child: PostPage(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/profile',
          parentNavigatorKey: shellNavigatorKey,
          pageBuilder: (context, state) => const MaterialPage(
            child: ProfilePage(),
          ),
        ),
        GoRoute(
          path: '/settings',
          parentNavigatorKey: shellNavigatorKey,
          pageBuilder: (context, state) => const MaterialPage(
            child: SettingsPage(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/new',
      parentNavigatorKey: navigatorKey,
      pageBuilder: (context, state) => const MaterialPage(
        child: PostNewPage(),
      ),
    ),
  ],
);
