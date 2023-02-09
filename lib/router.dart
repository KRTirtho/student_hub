import 'package:catcher/catcher.dart';
import 'package:student_hub/collections/env.dart';
import 'package:student_hub/models/book.dart';
import 'package:student_hub/models/book_tags.dart';
import 'package:student_hub/models/post.dart';
import 'package:student_hub/pages/banned/banned.dart';
import 'package:student_hub/pages/library/book_new.dart';
import 'package:student_hub/pages/library/book_search.dart';
import 'package:student_hub/pages/library/library.dart';
import 'package:student_hub/pages/media/image.dart';
import 'package:student_hub/pages/login/forgot_password.dart';
import 'package:student_hub/pages/login/login.dart';
import 'package:student_hub/pages/media/pdf.dart';
import 'package:student_hub/pages/notifications/notifications.dart';
import 'package:student_hub/pages/posts/post.dart';
import 'package:student_hub/pages/posts/post_new.dart';
import 'package:student_hub/pages/posts/post_search.dart';
import 'package:student_hub/pages/posts/posts.dart';
import 'package:student_hub/pages/profile/profile.dart';
import 'package:student_hub/pages/settings/about.dart';
import 'package:student_hub/pages/settings/settings.dart';
import 'package:student_hub/pages/signup/signup.dart';
import 'package:student_hub/pages/signup/verfication.dart';
import 'package:student_hub/providers/authentication_provider.dart';
import 'package:student_hub/shell.dart';
import 'package:student_hub/utils/transparent_route.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfx/pdfx.dart';
import 'package:riverpod/riverpod.dart';

final routerConfig = Provider((ref) {
  final navigatorKey = Catcher.navigatorKey;
  final shellNavigatorKey = GlobalKey<NavigatorState>();

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
              final auth = ref.read(authenticationProvider.notifier);
              final user = ref.read(authenticationProvider);
              if (!auth.isLoggedIn) {
                return "/login";
              }
              if (auth.isLoggedIn &&
                  user?.verified != true &&
                  Env.verifyEmail) {
                return "/verification";
              }
              if (auth.isLoggedIn && user!.isBanned) {
                return "/banned";
              }
              return null;
            },
            routes: [
              GoRoute(
                path: 'posts/:id',
                parentNavigatorKey: navigatorKey,
                pageBuilder: (context, state) => MaterialPage(
                  child: PostPage(
                    postId: state.params['id']!,
                    highlightComment: state.queryParams["comment"],
                  ),
                ),
              ),
              GoRoute(
                path: 'new',
                parentNavigatorKey: navigatorKey,
                pageBuilder: (context, state) => MaterialPage(
                  child: PostNewPage(
                    type: state.queryParams["type"],
                    post: state.extra as Post?,
                  ),
                ),
              ),
              GoRoute(
                path: 'search',
                parentNavigatorKey: shellNavigatorKey,
                pageBuilder: (context, state) => const MaterialPage(
                  child: PostSearchPage(),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/announcement',
            parentNavigatorKey: shellNavigatorKey,
            pageBuilder: (context, state) => MaterialPage(
              child: PostsPage(type: PostType.announcement.name),
            ),
          ),
          GoRoute(
            path: '/notifications',
            parentNavigatorKey: shellNavigatorKey,
            pageBuilder: (context, state) => const MaterialPage(
              child: NotificationsPage(),
            ),
          ),
          GoRoute(
            path: '/profile/:id',
            parentNavigatorKey: shellNavigatorKey,
            pageBuilder: (context, state) => MaterialPage(
              child: ProfilePage(userId: state.params['id']!),
            ),
          ),
          GoRoute(
            path: '/library',
            parentNavigatorKey: shellNavigatorKey,
            pageBuilder: (context, state) => const MaterialPage(
              child: LibraryPage(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                parentNavigatorKey: navigatorKey,
                pageBuilder: (context, state) => MaterialPage(
                  child: BookNewPage(
                    book: state.extra as Book?,
                  ),
                ),
              ),
              GoRoute(
                path: 'search',
                parentNavigatorKey: shellNavigatorKey,
                pageBuilder: (context, state) => MaterialPage(
                  child: BookSearchPage(
                    initialTags: state.extra as List<BookTag>?,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      //? ============ Outside of Shell ==================== ?//
      GoRoute(
        path: "/banned",
        pageBuilder: (context, state) => const MaterialPage(
          child: BannedPage(),
        ),
        redirect: (context, state) {
          final auth = ref.read(authenticationProvider.notifier);
          final user = ref.read(authenticationProvider);
          if (auth.isLoggedIn && !user!.isBanned) {
            return "/";
          }
          return null;
        },
      ),
      GoRoute(
        path: '/media/image',
        parentNavigatorKey: navigatorKey,
        pageBuilder: (context, state) => MaterialTransparentPage(
          child: ImagePage(
            medias: state.extra as List<Uri>,
            initialPage: state.queryParams["initialPage"] != null
                ? int.parse(state.queryParams["initialPage"]!)
                : 0,
          ),
        ),
      ),
      GoRoute(
        path: '/media/pdf',
        parentNavigatorKey: navigatorKey,
        pageBuilder: (context, state) => MaterialTransparentPage(
          child: PdfViewPage(
            document: state.extra != null && state.extra is Future<PdfDocument>
                ? state.extra as Future<PdfDocument>
                : null,
            documentUrl: state.extra != null && state.extra is String
                ? state.extra as String
                : null,
          ),
        ),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: navigatorKey,
        pageBuilder: (context, state) => const MaterialPage(
          child: SettingsPage(),
        ),
        routes: [
          GoRoute(
            path: 'about',
            parentNavigatorKey: navigatorKey,
            pageBuilder: (context, state) => const MaterialPage(
              child: AboutPage(),
            ),
          ),
        ],
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
          final auth = ref.read(authenticationProvider.notifier);
          if (auth.isLoggedIn) {
            final user = ref.read(authenticationProvider);
            if (user!.isBanned) {
              return "/banned";
            }
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
          final auth = ref.read(authenticationProvider.notifier);
          if (auth.isLoggedIn) {
            final user = ref.read(authenticationProvider);
            if (!user!.verified && Env.verifyEmail) {
              return "/verification";
            }
            if (user.isBanned) {
              return "/banned";
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
