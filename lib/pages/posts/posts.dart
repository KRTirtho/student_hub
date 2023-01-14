import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:eusc_freaks/components/posts/post_card.dart';
import 'package:eusc_freaks/components/scrolling/waypoint.dart';
import 'package:eusc_freaks/models/post.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:eusc_freaks/queries/posts.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
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
      appBar: AppBar(
        primary: true,
        title: const Text("Eusc Freaks"),
        centerTitle: false,
        leading: const UniversalImage(path: "assets/logo.jpg", height: 40),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            onPressed: () {
              GoRouter.of(context).push("/search");
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              GoRouter.of(context).push("/settings");
            },
          ),
        ],
      ),
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
        child: ListView.separated(
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
    );
  }
}
