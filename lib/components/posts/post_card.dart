import 'package:eusc_freaks/models/post.dart';
import 'package:eusc_freaks/utils/number_ending_type.dart';
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
    final session = post.user?.currentSession;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: post.user?.isMaster == true
                              ? Colors.orange
                              : Colors.blueAccent[200]!,
                          width: 2,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(),
                    ),
                    Positioned(
                      right: 15,
                      bottom: -1,
                      child: Icon(
                        post.user?.isMaster == true
                            ? Icons.location_city_outlined
                            : Icons.school_sharp,
                        size: 15,
                        color: post.user?.isMaster == true
                            ? Colors.orange
                            : Colors.blue[300],
                      ),
                    )
                  ],
                ),
                const Gap(5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.user?.name ?? post.user?.username ?? '',
                        style: Theme.of(context).textTheme.titleSmall,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (post.user?.isMaster != true)
                        Text(
                          "B. ${session?.year}'s  ${session?.serial}${getNumberEnding(session?.serial ?? 999)} of C. ${session?.standard}",
                          style: Theme.of(context).textTheme.caption,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
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
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: chipThrils['color'],
                                    fontSize: 10,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  timeago.format(DateTime.parse(post.created)),
                  style: Theme.of(context).textTheme.caption,
                ),
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
