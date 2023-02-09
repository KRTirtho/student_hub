import 'package:student_hub/components/posts/post_card.dart';
import 'package:student_hub/components/scrolling/constrained_list_view.dart';
import 'package:student_hub/components/scrolling/waypoint.dart';
import 'package:student_hub/components/shared/root_app_bar.dart';
import 'package:student_hub/hooks/use_redirect.dart';
import 'package:student_hub/models/post.dart';
import 'package:student_hub/providers/authentication_provider.dart';
import 'package:student_hub/queries/posts.dart';
import 'package:student_hub/utils/crashlytics_query_builder.dart';
import 'package:student_hub/utils/platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostsPage extends HookConsumerWidget {
  final String type;
  PostsPage({
    Key? key,
    String? type,
  })  : type = type ?? "${PostType.question.name},${PostType.informative.name}",
        super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = useScrollController();

    final user = ref.watch(authenticationProvider);

    useRedirect("/login", user == null);

    useEffect(() {
      if (kIsMobile) {
        WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) {
            FlutterNativeSplash.remove();
          },
        );
      }
      return;
    }, []);

    return CrashlyticsInfiniteQueryBuilder(
        job: postsInfiniteQueryJob(type),
        externalData: null,
        builder: (context, postsQuery) {
          final posts = postsQuery.pages
              .expand<Post>((page) => page?.items.toList() ?? []);
          return HookBuilder(builder: (context) {
            useEffect(() {
              if (postsQuery.hasError) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (timeStamp) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(postsQuery.errors.last.toString()),
                      ),
                    );
                  },
                );
              }
              return;
            }, [postsQuery]);
            return Scaffold(
              appBar: RooAppBar(),
              floatingActionButton: (user?.isMaster != true &&
                          type != PostType.announcement.name) ||
                      user?.isMaster == true
                  ? FloatingActionButton(
                      onPressed: () {
                        GoRouter.of(context).push("/new?type=$type");
                      },
                      child: const Icon(Icons.add),
                    )
                  : null,
              body: Waypoint(
                controller: controller,
                onTouchEdge: () async {
                  if (postsQuery.hasNextPage) {
                    await postsQuery.fetchNextPage();
                  }
                },
                child: CrashlyticsInfiniteQueryBuilder(
                    job: postsInfiniteQueryJob(type),
                    externalData: null,
                    builder: (context, query) {
                      return RefreshIndicator(
                        onRefresh: postsQuery.refetchPages,
                        child: ConstrainedListView.separated(
                          constraints: const BoxConstraints(maxWidth: 600),
                          alignment: Alignment.center,
                          physics: const AlwaysScrollableScrollPhysics(),
                          controller: controller,
                          separatorBuilder: (context, index) => const Gap(10),
                          padding: const EdgeInsets.all(8),
                          itemCount: posts.length,
                          itemBuilder: (context, index) {
                            final post = posts.elementAt(index);

                            return PostCard(post: post);
                          },
                        ),
                      );
                    }),
              ),
            );
          });
        });
  }
}
