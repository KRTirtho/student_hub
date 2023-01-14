import 'package:eusc_freaks/models/post.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart' as timeago;

final chipOfType = {
  PostType.question: {
    'color': Colors.deepPurple,
    'backgroundColor': Colors.purple[100],
  },
  PostType.informative: {
    'color': Colors.blue,
    'backgroundColor': Colors.blue[100],
  },
  PostType.announcement: {
    'color': Colors.red,
    'backgroundColor': Colors.red[100],
  },
};

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
    final chipThrils = chipOfType[post.type]!;

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.user?.name ?? post.user?.username ?? '',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Gap(3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: chipThrils['backgroundColor']!,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: chipThrils['color']!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        post.type.name,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: chipThrils['color'],
                              fontSize: 10,
                            ),
                      ),
                    ),
                  ],
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
                child: Text(
                  post.type == PostType.question ? "Solve" : "Comments",
                ),
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
