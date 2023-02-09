import 'package:carousel_slider/carousel_slider.dart';
import 'package:student_hub/collections/pocketbase.dart';
import 'package:student_hub/components/image/avatar.dart';
import 'package:student_hub/components/image/universal_image.dart';
import 'package:student_hub/components/posts/hazard_prompt_dialog.dart';
import 'package:student_hub/components/report/report_dialog.dart';
import 'package:student_hub/models/post.dart';
import 'package:student_hub/models/report.dart';
import 'package:student_hub/providers/authentication_provider.dart';
import 'package:student_hub/utils/number_ending_type.dart';
import 'package:fl_query/fl_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher_string.dart';

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

class PostCard extends StatefulHookConsumerWidget {
  final Post post;
  final bool expanded;
  const PostCard({
    Key? key,
    required this.post,
    this.expanded = false,
  }) : super(key: key);

  @override
  ConsumerState<PostCard> createState() => _PostCardState();
}

class _PostCardState extends ConsumerState<PostCard> {
  late final CarouselController carouselController;

  @override
  void initState() {
    super.initState();
    carouselController = CarouselController();
  }

  @override
  Widget build(BuildContext context) {
    final isAuthor =
        widget.post.user?.id == ref.watch(authenticationProvider)?.id;

    final chipThrills = chipOfType[widget.post.type]!;
    final session = widget.post.user?.currentSession;
    final medias = widget.post.getMediaURL(const Size(0, 200));
    final fullLengthMedia = widget.post.getMediaURL();

    final isLengthy = widget.post.description.split("\n").length > 6;
    final isLong = widget.post.description.length > 200;
    final isHide = useState(true);
    final description = isLengthy && isHide.value && !widget.expanded
        ? "${widget.post.description.split("\n").sublist(0, 6).join("\n")}..."
        : isLong && !isLengthy && isHide.value && !widget.expanded
            ? "${widget.post.description.substring(0, 200)} ..."
            : widget.post.description;

    final markdownConfig = MarkdownConfig(
      configs: [
        if (Theme.of(context).brightness == Brightness.dark) ...[
          HrConfig.darkConfig,
          H1Config.darkConfig,
          H2Config.darkConfig,
          H3Config.darkConfig,
          H4Config.darkConfig,
          H5Config.darkConfig,
          H6Config.darkConfig,
          PreConfig.darkConfig,
          PConfig.darkConfig,
          CodeConfig.darkConfig,
        ],
        ImgConfig(builder: (_, attr) {
          return GestureDetector(
            onTap: () {
              if (attr['src']?.isNotEmpty == true &&
                  Uri.tryParse(attr['src']!) != null) {
                launchUrlString(
                  attr['src']!,
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.image_outlined,
                  color: Colors.blue[800],
                  size: 16,
                ),
                Text(
                  attr['alt'] ?? '[Image URL]',
                  style: TextStyle(
                    color: Colors.blue[800],
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );

    final queryBowl = QueryBowl.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Avatar(user: widget.post.user!),
                const Gap(5),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          if (widget.post.user?.id ==
                              ref.read(authenticationProvider)?.id) {
                            GoRouter.of(context).go(
                              "/profile/authenticated",
                            );
                          } else {
                            GoRouter.of(context).push(
                              "/profile/${widget.post.user?.id}",
                            );
                          }
                        },
                        child: Text(
                          widget.post.user?.name ??
                              widget.post.user?.username ??
                              '',
                          style: Theme.of(context).textTheme.titleSmall,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        widget.post.user?.isMaster == true
                            ? "${session?.subject?.formattedName} Teacher since ${session?.year}"
                            : "B. ${session?.year}'s  ${session?.serial}${getNumberEnding(session?.serial ?? 999)} of C. ${session?.standard}",
                        style: Theme.of(context).textTheme.bodySmall,
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
                          color: chipThrills['backgroundColor']!,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: chipThrills['color']!,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          widget.post.type.name,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: chipThrills['color'],
                                    fontSize: 10,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    PopupMenuButton(
                      icon: const Icon(Icons.more_horiz),
                      onSelected: (value) async {
                        switch (value) {
                          case "edit":
                            GoRouter.of(context)
                                .push("/new?isEdit=true", extra: widget.post);
                            break;
                          case "delete":
                            final hasConfirmed = await showDialog<bool>(
                              context: context,
                              builder: (_) =>
                                  const HazardPromptDialog(type: "post"),
                            );
                            if (hasConfirmed == true) {
                              await pb
                                  .collection("posts")
                                  .delete(widget.post.id);
                              await Future.wait(
                                queryBowl.cache.infiniteQueries
                                    .where(
                                      (element) => element.queryKey
                                          .startsWith("posts-query"),
                                    )
                                    .map(
                                      (e) => Future.delayed(
                                        const Duration(milliseconds: 300),
                                        e.refetchPages,
                                      ),
                                    ),
                              );
                            }
                            break;
                          case "share":
                            break;
                          case "report":
                            showDialog(
                              context: context,
                              builder: (_) => ReportDialog(
                                collection: ReportCollection.post,
                                recordId: widget.post.id,
                              ),
                            );
                            break;
                        }
                      },
                      itemBuilder: (context) {
                        return [
                          if (isAuthor)
                            const PopupMenuItem(
                              value: "edit",
                              child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text("Edit"),
                              ),
                            ),
                          const PopupMenuItem(
                            value: "share",
                            child: ListTile(
                              leading: Icon(Icons.share),
                              title: Text("Share"),
                            ),
                          ),
                          if (isAuthor)
                            PopupMenuItem(
                              value: "delete",
                              child: ListTile(
                                iconColor: Colors.red[400],
                                leading:
                                    const Icon(Icons.delete_forever_outlined),
                                title: const Text("Delete"),
                              ),
                            ),
                          if (!isAuthor)
                            const PopupMenuItem(
                              value: "report",
                              child: ListTile(
                                leading: Icon(Icons.report),
                                title: Text("Report"),
                              ),
                            ),
                        ];
                      },
                    ),
                    Text(
                      timeago.format(DateTime.parse(widget.post.created)),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const Gap(20),
            Text(widget.post.title,
                style: Theme.of(context).textTheme.titleSmall),
            const Gap(20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MarkdownWidget(
                  padding: EdgeInsets.zero,
                  data: description,
                  config: markdownConfig,
                  selectable: true,
                  shrinkWrap: true,
                ),
                if ((isLengthy || isLong) && !widget.expanded)
                  Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                      onTap: () {
                        isHide.value = !isHide.value;
                      },
                      child: Text(
                        !isHide.value ? "... Show Less" : "... Show More",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isHide.value ? Colors.purple[600] : null,
                            ),
                      ),
                    ),
                  ),
              ],
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
                                GoRouter.of(context).push(
                                  "/media/image?initialPage=$index",
                                  extra: fullLengthMedia,
                                );
                              },
                              child: Center(
                                child: Hero(
                                  tag: fullLengthMedia[index],
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
                                  color: Theme.of(context)
                                      .colorScheme
                                      .background
                                      .withOpacity(.5),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  "${index + 1}/${medias.length}",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
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
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .background
                                    .withOpacity(.5)),
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
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .background
                                    .withOpacity(.5)),
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
            if (!widget.expanded)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(40),
                ),
                child: Text(
                  widget.post.type == PostType.question ? "Solve" : "Comments",
                ),
                onPressed: () {
                  GoRouter.of(context).push("/posts/${widget.post.id}");
                },
              ),
          ],
        ),
      ),
    );
  }
}
