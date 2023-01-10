import 'package:eusc_freaks/components/posts/post_card.dart';
import 'package:eusc_freaks/queries/posts.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PostPage extends HookConsumerWidget {
  final String postId;
  const PostPage({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final postQuery = useQuery(job: postQueryJob(postId), externalData: null);

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          if (postQuery.hasData)
            PostCard(post: postQuery.data!, expanded: true)
          else
            const CircularProgressIndicator.adaptive()
        ],
      ),
    );
  }
}
