import 'dart:ui';

import 'package:student_hub/collections/pocketbase.dart';
import 'package:student_hub/components/posts/post_card.dart';
import 'package:student_hub/components/posts/post_comment.dart';
import 'package:student_hub/components/posts/post_comment_media.dart';
import 'package:student_hub/components/scrolling/constrained_list_view.dart';
import 'package:student_hub/components/scrolling/waypoint.dart';
import 'package:student_hub/hooks/use_auto_scroll_controller.dart';
import 'package:student_hub/hooks/use_crashlytics_query.dart';
import 'package:student_hub/models/comment.dart';
import 'package:student_hub/models/lol_file.dart';
import 'package:student_hub/models/post.dart';
import 'package:student_hub/providers/authentication_provider.dart';
import 'package:student_hub/queries/posts.dart';
import 'package:student_hub/utils/platform.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:collection/collection.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class PostPage extends HookConsumerWidget {
  final String postId;
  final String? highlightComment;
  const PostPage({
    Key? key,
    required this.postId,
    this.highlightComment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final user = ref.watch(authenticationProvider);

    final controller = useAutoScrollController();

    final postQuery = useCrashlyticsQuery(
      job: postQueryJob(postId),
      externalData: null,
    );
    final commentsQuery = useCrashlyticsInfiniteQuery(
      job: postCommentsInfiniteQueryJob(postId),
      externalData: null,
    );

    final comments = commentsQuery.pages
        .map((page) => page?.items ?? [])
        .expand((element) => element)
        .toList();

    useEffect(() {
      if (highlightComment == null || commentsQuery.pages.first == null) {
        return null;
      }
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        final index =
            comments.indexWhere((element) => element.id == highlightComment);
        if (index > -1) {
          await controller.scrollToIndex(
            index,
            preferPosition: AutoScrollPosition.begin,
          );
          return;
        }
        final comment = await pb
            .collection("comments")
            .getOne(highlightComment!, expand: "user");
        commentsQuery.setQueryData(
          (oldData) => {
            ...?oldData,
            commentsQuery.pageParams.first: ResultList(
              items: [
                ...?oldData?[commentsQuery.pageParams.first]?.items,
                Comment.fromRecord(comment),
              ],
              page: oldData?[commentsQuery.pageParams.first]?.page ?? 1,
              perPage: oldData?[commentsQuery.pageParams.first]?.perPage ?? 10,
              totalItems:
                  oldData?[commentsQuery.pageParams.first]?.totalItems ?? 10,
              totalPages:
                  oldData?[commentsQuery.pageParams.first]?.totalPages ?? 1,
            ),
          },
        );
      });
      return null;
    }, [highlightComment, comments, commentsQuery.pages]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await pb.collection("comments").subscribe("*", (event) async {
          if (event.record?.data["post"] == postId) {
            commentsQuery.setQueryData(
              (oldData) async {
                switch (event.action) {
                  case "create":
                    {
                      final oldResultList =
                          commentsQuery.data?[commentsQuery.pageParams.first];
                      if (oldResultList?.items.any(
                              (element) => element.id == event.record?.id) ??
                          false) {
                        return oldData ?? {};
                      }
                      final rec = event.record!.toJson();
                      rec["expand"]["user"] =
                          (await pb.collection("users").getOne(
                                    event.record?.data["user"],
                                  ))
                              .toJson();
                      final comment = Comment.fromJson(rec);
                      return {
                        ...?oldData,
                        commentsQuery.pageParams.first: ResultList(
                          items: [
                            ...?oldResultList?.items.where((e) => e.solve),
                            comment,
                            ...?oldResultList?.items.where((e) => !e.solve),
                          ],
                          page: oldResultList?.page ?? 1,
                          perPage: oldResultList?.perPage ?? 10,
                          totalItems: oldResultList?.totalItems ?? 10,
                          totalPages: oldResultList?.totalPages ?? 1,
                        ),
                      };
                    }
                  case "delete":
                    {
                      final comment = Comment.fromRecord(event.record!);
                      final param = oldData?.entries
                          .toList()
                          .firstWhereOrNull(
                            (element) =>
                                element.value?.items.any(
                                  (element) => element.id == comment.id,
                                ) ==
                                true,
                          )
                          ?.key;
                      if (param == null) return oldData ?? {};
                      return {
                        ...?oldData,
                        param: ResultList(
                          items: oldData?[param]
                                  ?.items
                                  .where((element) => element.id != comment.id)
                                  .toList() ??
                              [],
                          page: oldData?[param]?.page ?? 1,
                          perPage: oldData?[param]?.perPage ?? 10,
                          totalItems: oldData?[param]?.totalItems ?? 10,
                          totalPages: oldData?[param]?.totalPages ?? 1,
                        ),
                      };
                    }
                  case "update":
                    {
                      final comment = Comment.fromRecord(event.record!);
                      final param = oldData?.entries
                          .toList()
                          .firstWhereOrNull(
                            (element) =>
                                element.value?.items.any(
                                  (element) => element.id == comment.id,
                                ) ==
                                true,
                          )
                          ?.key;
                      if (param == null) return oldData ?? {};
                      return {
                        ...?oldData,
                        param: ResultList(
                          items: oldData?[param]?.items.map((e) {
                                if (e.id == comment.id) {
                                  return Comment.fromJson({
                                    ...comment.toJson(),
                                    "expand": {"user": e.user?.toJson()}
                                  });
                                }
                                return e;
                              }).toList() ??
                              [],
                          page: oldData?[param]?.page ?? 1,
                          perPage: oldData?[param]?.perPage ?? 10,
                          totalItems: oldData?[param]?.totalItems ?? 10,
                          totalPages: oldData?[param]?.totalPages ?? 1,
                        ),
                      };
                    }
                  default:
                    return oldData ?? {};
                }
              },
            );
          }
        });
      });
      return () {
        pb.collection("comments").unsubscribe("*");
      };
    }, []);

    final isAlreadySolved = comments.any((e) => e.solve);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post"),
        centerTitle: true,
      ),
      extendBody: true,
      body: Stack(
        children: [
          Waypoint(
            controller: controller,
            onTouchEdge: () {
              if (commentsQuery.hasNextPage) commentsQuery.fetchNextPage();
            },
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.wait([
                  postQuery.refetch(),
                  commentsQuery.refetchPages(),
                ]);
              },
              child: ConstrainedListView(
                constraints: const BoxConstraints(maxWidth: 600),
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                physics: const AlwaysScrollableScrollPhysics(),
                controller: controller,
                children: [
                  if (postQuery.hasData && !postQuery.hasError) ...[
                    PostCard(post: postQuery.data!, expanded: true),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        postQuery.data!.type == PostType.question
                            ? "Solutions"
                            : "Comments",
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ] else if (postQuery.hasError &&
                      postQuery.error is ClientException)
                    Center(
                      child: Text(
                        (postQuery.error as ClientException)
                                .response["message"] ??
                            "",
                      ),
                    )
                  else
                    const Center(child: CircularProgressIndicator.adaptive()),
                  ...comments.mapIndexed(
                    (index, comment) {
                      return AutoScrollTag(
                        controller: controller,
                        index: index,
                        key: ValueKey(comment.id),
                        child: PostComment(
                          isSolvable:
                              postQuery.data?.type == PostType.question &&
                                  !comment.solve &&
                                  !isAlreadySolved &&
                                  postQuery.data?.user?.id == user?.id,
                          postId: postId,
                          comment: comment,
                          isHighlighted: comment.id == highlightComment,
                          onSolveToggle: (solved) async {
                            await pb.collection("comments").update(
                              comment.id,
                              body: {
                                "solve": solved,
                              },
                            );
                            await commentsQuery.refetchPages();
                          },
                        ),
                      );
                    },
                  ),
                  const Gap(80),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: HookBuilder(
              builder: (context) {
                final medias = useState<List<LOLFile>>([]);
                final updating = useState(false);

                final commentController = useTextEditingController();
                void comment() async {
                  if (commentController.text.isEmpty) return;
                  updating.value = true;

                  await pb.collection("comments").create(
                    body: {
                      "comment": commentController.text.trim(),
                      "post": postId,
                      "user": ref.read(authenticationProvider)?.id,
                    },
                    files: await Future.wait(
                      medias.value.map(
                        (e) {
                          return e.toMultipartFile("media");
                        },
                      ),
                    ),
                  );
                  await commentsQuery.refetchPages();
                  medias.value = [];
                  commentController.clear();
                  updating.value = false;
                }

                final focusNode = useFocusNode(
                  onKey: (node, event) {
                    if (kIsDesktop &&
                        event.isKeyPressed(LogicalKeyboardKey.enter) &&
                        event.isShiftPressed) {
                      comment();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                );

                final addMedia = updating.value
                    ? null
                    : () async {
                        final files = await FilePicker.platform.pickFiles(
                          allowMultiple: true,
                          dialogTitle: "Select post media",
                          type: FileType.image,
                          withData: true,
                        );
                        if (files == null) return;
                        if ((files.count + medias.value.length) > 3) {
                          medias.value = [
                            ...medias.value,
                            ...files.files
                                .sublist(0, 3 - medias.value.length)
                                .map(
                                    (e) => LOLFile.fromPlatformFile(e, "image"))
                          ];
                        } else {
                          medias.value = [
                            ...medias.value,
                            ...files.files.map(
                                (e) => LOLFile.fromPlatformFile(e, "image"))
                          ];
                        }
                      };
                return Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(.3),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (medias.value.isNotEmpty) ...[
                          const Gap(10),
                          PostCommentMedia(
                            medias: medias.value,
                            enabled: !updating.value,
                            onChanged: (value) {
                              medias.value = value;
                            },
                          ),
                          const Gap(10),
                        ],
                        TextField(
                          focusNode: focusNode,
                          controller: commentController,
                          minLines: 1,
                          maxLines: 2,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.transparent,
                            isDense: true,
                            labelText: postQuery.data?.type == PostType.question
                                ? 'Answer'
                                : 'Comment',
                            border: const UnderlineInputBorder(),
                            suffix: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (medias.value.isEmpty)
                                  IconButton(
                                    icon: const Icon(
                                        Icons.add_photo_alternate_outlined),
                                    onPressed: addMedia,
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: updating.value ? null : comment,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
