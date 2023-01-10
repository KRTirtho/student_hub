import 'package:eusc_freaks/models/post.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends HookConsumerWidget {
  final Post post;
  final bool expanded;
  const PostCard({
    Key? key,
    required this.post,
    this.expanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(),
                const Gap(5),
                Text(
                  post.user?.name ?? post.user?.username ?? '',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(timeago.format(DateTime.parse(post.created))),
              ],
            ),
            const Gap(20),
            Text(post.title, style: Theme.of(context).textTheme.titleSmall),
            const Gap(20),
            ReadMoreText(
              "${post.description} ",
              moreStyle: Theme.of(context).textTheme.caption,
              lessStyle: Theme.of(context).textTheme.caption,
              trimMode: TrimMode.Line,
              trimLines: 6,
            ),
            const Gap(20),
            if (!expanded)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                child: const Text("Comments"),
                onPressed: () {
                  GoRouter.of(context).push("/posts/${post.id}");
                },
              ),
          ],
        ),
      ),
    );
  }
}
