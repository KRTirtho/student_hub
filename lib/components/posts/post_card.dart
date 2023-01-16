import 'package:carousel_slider/carousel_slider.dart';
import 'package:eusc_freaks/components/image/avatar.dart';
import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:eusc_freaks/components/posts/post_media.dart';
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
  PostCard({
    Key? key,
    required this.post,
    this.expanded = false,
  }) : super(key: key);

  final carouselController = CarouselController();

  @override
  Widget build(BuildContext context, ref) {
    final chipThrils = chipOfType[post.type]!;
    final session = post.user?.currentSession;
    final medias = post.getMediaURL();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Avatar(user: post.user!),
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
                      Text(
                        post.user?.isMaster == true
                            ? "${session?.subject?.formattedName} Teacher since ${session?.year}"
                            : "B. ${session?.year}'s  ${session?.serial}${getNumberEnding(session?.serial ?? 999)} of C. ${session?.standard}",
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
            if (medias.isNotEmpty)
              Stack(
                children: [
                  CarouselSlider.builder(
                    itemCount: medias.length,
                    options: CarouselOptions(
                      height: 200,
                      viewportFraction: 1,
                      enableInfiniteScroll: medias.length > 1,
                      enlargeCenterPage: true,
                      enlargeStrategy: CenterPageEnlargeStrategy.height,
                      scrollPhysics: const RangeMaintainingScrollPhysics(),
                    ),
                    carouselController: carouselController,
                    itemBuilder: (context, index, realIndex) {
                      final media = medias[index].toString();
                      return Stack(
                        children: [
                          Positioned.fill(
                            child: MaterialButton(
                              padding: EdgeInsets.zero,
                              color: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => PostMedia(
                                    medias: medias,
                                    initialPage: index,
                                  ),
                                );
                              },
                              child: Center(
                                child: Hero(
                                  tag: media,
                                  transitionOnUserGestures: true,
                                  child: Container(
                                    height: 200,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image:
                                            UniversalImage.imageProvider(media),
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (medias.length > 1)
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  "${index + 1}/${medias.length}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .caption
                                      ?.copyWith(
                                        color: Colors.white,
                                      ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  if (medias.length > 1) ...[
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            style: IconButton.styleFrom(
                                backgroundColor: Colors.white38),
                            icon: const Icon(Icons.chevron_left),
                            onPressed: () {
                              carouselController.previousPage();
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: IconButton(
                            style: IconButton.styleFrom(
                                backgroundColor: Colors.white38),
                            icon: const Icon(Icons.chevron_right),
                            onPressed: () {
                              carouselController.nextPage();
                            },
                          ),
                        ),
                      ),
                    ),
                  ]
                ],
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
