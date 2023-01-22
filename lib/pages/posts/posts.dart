import 'package:eusc_freaks/components/posts/post_card.dart';
import 'package:eusc_freaks/components/scrolling/constrained_list_view.dart';
import 'package:eusc_freaks/components/scrolling/waypoint.dart';
import 'package:eusc_freaks/components/shared/root_app_bar.dart';
import 'package:eusc_freaks/hooks/use_redirect.dart';
import 'package:eusc_freaks/models/post.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:eusc_freaks/queries/posts.dart';
import 'package:eusc_freaks/utils/platform.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
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
    final postsQuery = useInfiniteQuery(
      job: postsInfiniteQueryJob(type),
      externalData: null,
    );
    final user = ref.watch(authenticationProvider);

    final posts =
        postsQuery.pages.expand<Post>((page) => page?.items.toList() ?? []);

    useRedirect("/login", user == null);

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

    return Scaffold(
      appBar: RooAppBar(),
      floatingActionButton:
          (user?.isMaster != true && type != PostType.announcement.name) ||
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
        child: RefreshIndicator(
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
        ),
      ),
    );
  }
}
