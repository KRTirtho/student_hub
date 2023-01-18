import 'package:eusc_freaks/components/image/avatar.dart';
import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:eusc_freaks/hooks/use_brightness_value.dart';
import 'package:eusc_freaks/models/comment.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart';
import 'package:collection/collection.dart';

class PostComment extends HookConsumerWidget {
  final Comment comment;
  final bool isSolvable;
  final ValueChanged<bool>? onSolveToggle;
  const PostComment({
    Key? key,
    required this.comment,
    required this.isSolvable,
    this.onSolveToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final urls = comment.getMediaURL(const Size(0, 100));
    final fullLengthUrls = comment.getMediaURL();

    final color = useBrightnessValue(
        Colors.green[100], Colors.green[900]?.withOpacity(.5));

    final badgeColor = useBrightnessValue(
      Colors.green[600],
      Colors.green[300],
    );

    Widget child = Card(
      color: comment.solve ? color : null,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Avatar(user: comment.user!, radius: 12),
                const Gap(5),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        if (comment.user?.id ==
                            ref.read(authenticationProvider)?.id) {
                          GoRouter.of(context).go(
                            "/profile/authenticated",
                          );
                        } else {
                          GoRouter.of(context).push(
                            "/profile/${comment.user?.id}",
                          );
                        }
                      },
                      child: Text(
                        comment.user!.name ?? comment.user!.username,
                        style: Theme.of(context).textTheme.labelMedium!,
                      ),
                    ),
                    Text(
                      format(DateTime.parse(comment.created)),
                      style: Theme.of(context).textTheme.caption!,
                    ),
                  ],
                ),
                const Spacer(),
                PopupMenuButton(
                  icon: const Icon(Icons.more_horiz_outlined),
                  onSelected: (value) {
                    switch (value) {
                      case "solve":
                        {
                          onSolveToggle?.call(true);
                          break;
                        }
                      case "unsolve":
                        {
                          onSolveToggle?.call(false);
                          break;
                        }
                      case "report":
                        break;
                      default:
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      if (isSolvable)
                        PopupMenuItem(
                          value: "solve",
                          child: Row(
                            children: const [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.green,
                              ),
                              Gap(5),
                              Text("Solve"),
                            ],
                          ),
                        ),
                      if (comment.solve)
                        PopupMenuItem(
                          value: "unsolve",
                          child: Row(
                            children: const [
                              Icon(
                                Icons.check_circle_outline,
                                color: Colors.red,
                              ),
                              Gap(5),
                              Text("Unsolve"),
                            ],
                          ),
                        ),
                      const PopupMenuItem(
                        value: "report",
                        child: Text("Report"),
                      ),
                    ];
                  },
                ),
              ],
            ),
            const Gap(10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: ReadMoreText(
                "${comment.comment} ",
                trimMode: TrimMode.Line,
                trimLines: 3,
                style: Theme.of(context).textTheme.bodyMedium,
                lessStyle: Theme.of(context).textTheme.caption,
                moreStyle: Theme.of(context).textTheme.caption,
              ),
            ),
            const Gap(10),
            Row(
              children: [
                ...urls.mapIndexed(
                  (index, url) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () {
                            GoRouter.of(context).push(
                              "/media/image?initialPage=$index",
                              extra: fullLengthUrls,
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: Hero(
                              tag: fullLengthUrls[index],
                              transitionOnUserGestures: true,
                              child: UniversalImage(
                                path: url.toString(),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator.adaptive(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (comment.solve) {
      child = Stack(
        children: [
          child,
          Positioned(
            bottom: 3,
            right: 5,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: badgeColor!, width: 2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: badgeColor,
                    size: 15,
                  ),
                  Text(
                    "Accepted Answer",
                    style: TextStyle(color: badgeColor, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return child;
  }
}
