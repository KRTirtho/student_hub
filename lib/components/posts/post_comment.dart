import 'package:eusc_freaks/components/image/avatar.dart';
import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:eusc_freaks/models/comment.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart';
import 'package:collection/collection.dart';

class PostComment extends HookConsumerWidget {
  final Comment comment;
  const PostComment({
    Key? key,
    required this.comment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final urls = comment.getMediaURL(const Size(0, 100));
    final fullLengthUrls = comment.getMediaURL();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Avatar(user: comment.user!, radius: 10),
                const Gap(5),
                Text(
                  comment.user!.name ?? comment.user!.username,
                  style: Theme.of(context).textTheme.labelMedium!,
                ),
                const Spacer(),
                Text(
                  format(DateTime.parse(comment.created)),
                  style: Theme.of(context).textTheme.labelSmall!,
                ),
              ],
            ),
            const Gap(10),
            ReadMoreText(
              "${comment.comment} ",
              trimMode: TrimMode.Line,
              trimLines: 3,
              style: Theme.of(context).textTheme.bodyMedium,
              lessStyle: Theme.of(context).textTheme.caption,
              moreStyle: Theme.of(context).textTheme.caption,
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
  }
}
