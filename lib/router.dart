import 'package:eusc_freaks/collections/env.dart';
import 'package:eusc_freaks/pages/login/forgot_password.dart';
import 'package:eusc_freaks/pages/login/login.dart';
import 'package:eusc_freaks/pages/posts/post.dart';
import 'package:eusc_freaks/pages/posts/post_new.dart';
import 'package:eusc_freaks/pages/posts/posts.dart';
import 'package:eusc_freaks/pages/profile/profile.dart';
import 'package:eusc_freaks/pages/settings/settings.dart';
import 'package:eusc_freaks/pages/signup/signup.dart';
import 'package:eusc_freaks/pages/signup/verfication.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:eusc_freaks/shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod/riverpod.dart';

final routerConfig = Provider((ref) {
  final navigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();
  final auth = ref.watch(authenticationProvider.notifier);
  final user = ref.watch(authenticationProvider);

  return GoRouter(
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
            pageBuilder: (context, state) => MaterialPage(
              child: PostsPage(
                type: state.queryParams["type"],
              ),
            ),
            redirect: (context, state) {
              if (!auth.isLoggedIn) {
                return "/login";
              } else if (auth.isLoggedIn &&
                  user?.verified != true &&
                  Env.verifyEmail) {
                return "/verification";
              }
              return null;
            },
            routes: [
              GoRoute(
                path: 'posts/:id',
                parentNavigatorKey: navigatorKey,
                pageBuilder: (context, state) => MaterialPage(
                  child: PostPage(postId: state.params['id']!),
                ),
              ),
              GoRoute(
                path: 'new',
                parentNavigatorKey: navigatorKey,
                pageBuilder: (context, state) => MaterialPage(
                  child: PostNewPage(type: state.queryParams["type"]),
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
        ],
      ),

      //? ============ Outside of Shell ==================== ?//
      GoRoute(
        path: '/settings',
        parentNavigatorKey: navigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: SettingsPage(),
        ),
      ),

      GoRoute(
        path: '/login',
        parentNavigatorKey: navigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: LoginPage(),
        ),
        routes: [
          GoRoute(
            path: 'forgot-password',
            parentNavigatorKey: navigatorKey,
            pageBuilder: (context, state) => const MaterialPage(
              child: ForgotPasswordPage(),
            ),
          ),
        ],
        redirect: (context, state) {
          if (auth.isLoggedIn) {
            return "/";
          }
          return null;
        },
      ),
      GoRoute(
        path: '/signup',
        parentNavigatorKey: navigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: SignupPage(),
        ),
        redirect: (context, state) {
          if (auth.isLoggedIn) {
            if (!user!.verified && Env.verifyEmail) {
              return "/verification";
            }
            return "/";
          }
          return null;
        },
      ),
      GoRoute(
        path: '/verification',
        parentNavigatorKey: navigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: VerificationPage(),
        ),
      )
    ],
  );
});
