import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:eusc_freaks/components/posts/post_card.dart';
import 'package:eusc_freaks/models/post.dart';
import 'package:eusc_freaks/queries/posts.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostsPage extends HookConsumerWidget {
  const PostsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final postsQuery =
        useInfiniteQuery(job: postsInfiniteQueryJob, externalData: null);

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
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              GoRouter.of(context).push("/settings");
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).push("/new");
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        separatorBuilder: (context, index) => const Gap(10),
        padding: const EdgeInsets.all(8),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts.elementAt(index);

          return PostCard(post: post);
        },
      ),
    );
  }
}
