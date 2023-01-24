import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/components/image/avatar.dart';
import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:eusc_freaks/components/posts/hazard_prompt_dialog.dart';
import 'package:eusc_freaks/components/posts/post_comment_media.dart';
import 'package:eusc_freaks/components/report/report_dialog.dart';
import 'package:eusc_freaks/hooks/use_brightness_value.dart';
import 'package:eusc_freaks/models/comment.dart';
import 'package:eusc_freaks/models/lol_file.dart';
import 'package:eusc_freaks/models/report.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:eusc_freaks/queries/posts.dart';
import 'package:fl_query/fl_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart';

class PostComment extends HookConsumerWidget {
  final Comment comment;
  final bool isSolvable;
  final String postId;
  final ValueChanged<bool>? onSolveToggle;
  final bool isHighlighted;
  const PostComment({
    Key? key,
    required this.comment,
    required this.isSolvable,
    required this.postId,
    this.onSolveToggle,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final isOwner = ref.watch(authenticationProvider)?.id == comment.user?.id;

    final isEditMode = useState(false);
    final updating = useState(false);
    final controller = useTextEditingController(text: comment.comment);

    final color = useBrightnessValue(
      Colors.green[100],
      Colors.green[900]?.withOpacity(.5),
    );

    final badgeColor = useBrightnessValue(
      Colors.green[600],
      Colors.green[300],
    );

    final urls = comment.getMediaURL(const Size(0, 100));
    final initialMedia = urls.map((e) => LOLFile.fromUri(e, "image")).toList();
    final medias = useState<List<LOLFile>>(initialMedia);
    final fullLengthUrls = comment.getMediaURL();

    final queryBowl = QueryBowl.of(context);

    final highlightColor = useBrightnessValue(
      Colors.yellow[100],
      Colors.yellow[900]?.withOpacity(.5),
    );
    Widget child = Card(
      color: comment.solve
          ? color
          : isHighlighted
              ? highlightColor
              : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: isHighlighted
            ? const BorderSide(color: Colors.yellow, width: 2)
            : BorderSide.none,
      ),
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
                  onSelected: (value) async {
                    switch (value) {
                      case "solve":
                      case "unsolve":
                        onSolveToggle?.call(value == "solve");
                        break;
                      case "edit":
                        isEditMode.value = true;
                        break;
                      case "delete":
                        final hasConfirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) =>
                              const HazardPromptDialog(type: 'comment'),
                        );
                        if (hasConfirmed == true) {
                          await pb.collection("comments").delete(comment.id);
                          await queryBowl
                              .getInfiniteQuery(
                                  postCommentsInfiniteQueryJob(postId).queryKey)
                              ?.refetchPages();
                        }
                        break;
                      case "report":
                        await showDialog(
                          context: context,
                          builder: (context) => ReportDialog(
                            collection: ReportCollection.comment,
                            recordId: comment.id,
                          ),
                        );
                        break;
                      default:
                    }
                  },
                  enabled: !updating.value && !isEditMode.value,
                  itemBuilder: (context) {
                    return [
                      if (isSolvable)
                        const PopupMenuItem(
                          value: "solve",
                          child: ListTile(
                            leading: Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                            ),
                            title: Text("Solve"),
                          ),
                        ),
                      if (comment.solve)
                        const PopupMenuItem(
                          value: "unsolve",
                          child: ListTile(
                            leading: Icon(
                              Icons.cancel_outlined,
                              color: Colors.red,
                            ),
                            title: Text("Unsolve"),
                          ),
                        ),
                      if (isOwner) ...[
                        const PopupMenuItem(
                          value: "edit",
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text("Edit"),
                          ),
                        ),
                        const PopupMenuItem(
                          value: "delete",
                          child: ListTile(
                            leading: Icon(Icons.delete_forever_outlined),
                            iconColor: Colors.red,
                            title: Text("Delete"),
                          ),
                        ),
                      ],
                      if (!isOwner)
                        const PopupMenuItem(
                          value: "report",
                          child: ListTile(
                            leading: Icon(Icons.report_outlined),
                            title: Text("Report"),
                          ),
                        ),
                    ];
                  },
                ),
              ],
            ),
            const Gap(10),
            if (isEditMode.value)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.multiline,
                      style: const TextStyle(fontSize: 14),
                      minLines: 1,
                      maxLines: 10,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: "Edit Comment",
                        isDense: true,
                        contentPadding: const EdgeInsets.all(8),
                        suffix: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            isEditMode.value = false;
                            controller.text = comment.comment;
                            medias.value = initialMedia;
                          },
                        ),
                      ),
                    ),
                  ),
                  const Gap(10),
                  ElevatedButton(
                    onPressed: updating.value
                        ? null
                        : () async {
                            updating.value = true;
                            try {
                              final newMedia = medias.value
                                  .where((e) => e.bytes != null)
                                  .toList();
                              final deletedMedia = initialMedia
                                  .where((e) => !medias.value.contains(e))
                                  .map((e) => e.name)
                                  .toList();

                              final files = await Future.wait(
                                newMedia.map((e) {
                                  return e.toMultipartFile("media");
                                }),
                              );

                              RecordModel record;
                              if (deletedMedia.isNotEmpty &&
                                  newMedia.isNotEmpty) {
                                record = await pb.collection("comments").update(
                                  comment.id,
                                  body: {
                                    "media-": deletedMedia,
                                  },
                                );
                              }

                              record = await pb.collection("comments").update(
                                    comment.id,
                                    body: {
                                      "comment": controller.text,
                                      if (deletedMedia.isNotEmpty &&
                                          newMedia.isEmpty)
                                        "media-": deletedMedia,
                                    },
                                    files: files,
                                  );

                              await queryBowl
                                  .getInfiniteQuery(
                                    postCommentsInfiniteQueryJob(
                                      record.data["post"],
                                    ).queryKey,
                                  )
                                  ?.refetch();
                              isEditMode.value = false;
                              controller.text = record.data["comment"];
                              medias.value = Comment.fromRecord(record)
                                  .getMediaURL(const Size(0, 100))
                                  .map((e) => LOLFile.fromUri(e, "image"))
                                  .toList();
                            } finally {
                              updating.value = false;
                            }
                          },
                    child: const Icon(Icons.save_outlined),
                  )
                ],
              )
            else
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
            if (isEditMode.value)
              PostCommentMedia(
                medias: medias.value,
                enabled: !updating.value,
                onChanged: (value) {
                  medias.value = value;
                },
              )
            else
              Row(
                children: [
                  for (final url in medias.value.asMap().entries)
                    Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () {
                            GoRouter.of(context).push(
                              "/media/image?initialPage=${url.key}",
                              extra: fullLengthUrls,
                            );
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            height: 100,
                            width: 100,
                            child: Hero(
                              tag: fullLengthUrls.isNotEmpty
                                  ? fullLengthUrls[url.key]
                                  : url.value.name,
                              transitionOnUserGestures: true,
                              child: UniversalImage(
                                path: url.value.universalPath,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator.adaptive(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
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
