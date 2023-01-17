import 'dart:ui';

import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/components/image/avatar.dart';
import 'package:eusc_freaks/components/image/universal_image.dart';
import 'package:eusc_freaks/components/posts/post_card.dart';
import 'package:eusc_freaks/components/scrolling/waypoint.dart';
import 'package:eusc_freaks/models/comment.dart';
import 'package:eusc_freaks/models/post.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:eusc_freaks/queries/posts.dart';
import 'package:eusc_freaks/utils/platform.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' hide ClientException;
import 'package:http_parser/http_parser.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart';
import 'package:collection/collection.dart';

class PostPage extends HookConsumerWidget {
  final String postId;
  const PostPage({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = useScrollController();

    final postQuery = useQuery(
      job: postQueryJob(postId),
      externalData: null,
    );
    final commentsQuery = useInfiniteQuery(
      job: postCommentsInfiniteQueryJob(postId),
      externalData: null,
    );

    final comments = commentsQuery.pages
        .map((page) => page?.items ?? [])
        .expand((element) => element)
        .toList();

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
                            comment,
                            ...?oldResultList?.items,
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post"),
        centerTitle: true,
      ),
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
              child: ListView(
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
                            .response["message"],
                      ),
                    )
                  else
                    const Center(child: CircularProgressIndicator.adaptive()),
                  ...comments.map(
                    (comment) {
                      final urls = comment.getMediaURL();
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
                                    comment.user!.name ??
                                        comment.user!.username,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium!,
                                  ),
                                  const Spacer(),
                                  Text(
                                    format(DateTime.parse(comment.created)),
                                    style:
                                        Theme.of(context).textTheme.labelSmall!,
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
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: InkWell(
                                            onTap: () {
                                              GoRouter.of(context).push(
                                                "/media/image?initialPage=$index",
                                                extra: urls,
                                              );
                                            },
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: SizedBox(
                                              height: 100,
                                              width: 100,
                                              child: Hero(
                                                tag: url.toString(),
                                                transitionOnUserGestures: true,
                                                child: UniversalImage(
                                                  path: url.toString(),
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      const Center(
                                                    child:
                                                        CircularProgressIndicator
                                                            .adaptive(),
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
                    },
                  ),
                  const Gap(80),
                ],
              ),
            ),
          ),
          HookBuilder(builder: (context) {
            final medias = useState<List<PlatformFile>>([]);
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
                files: medias.value
                    .map(
                      (e) => MultipartFile.fromBytes(
                        'media',
                        e.bytes!,
                        filename: e.name,
                        contentType: MediaType(
                          'image',
                          e.extension!,
                        ),
                      ),
                    )
                    .toList(),
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
                        ...files.files.sublist(0, 3 - medias.value.length),
                      ];
                    } else {
                      medias.value = [...medias.value, ...files.files];
                    }
                  };
            return Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).scaffoldBackgroundColor.withOpacity(.3),
                ),
                clipBehavior: Clip.antiAlias,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (medias.value.isNotEmpty) ...[
                        const Gap(10),
                        SizedBox(
                          height: 70,
                          child: Row(
                            children: [
                              const Gap(10),
                              ...medias.value.map(
                                (media) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Stack(
                                      children: [
                                        Container(
                                          height: 70,
                                          width: 70,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                            image: DecorationImage(
                                              image: MemoryImage(
                                                media.bytes!,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Positioned.fill(
                                          child: Center(
                                            child: IconButton(
                                              style: IconButton.styleFrom(
                                                backgroundColor: Colors.white60,
                                              ),
                                              color: Colors.red[400]
                                                  ?.withOpacity(.8),
                                              icon: const Icon(
                                                Icons.delete_outline_rounded,
                                              ),
                                              onPressed: () {
                                                medias.value = medias.value
                                                    .where(
                                                      (element) =>
                                                          element != media,
                                                    )
                                                    .toList();
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                width: 70,
                                child: MaterialButton(
                                  height: 80,
                                  color: Theme.of(context).cardColor,
                                  elevation: 0,
                                  focusElevation: 0,
                                  hoverElevation: 0,
                                  highlightElevation: 0,
                                  disabledElevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  onPressed: addMedia,
                                  child: const Icon(
                                    Icons.add_photo_alternate_outlined,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(10),
                      ],
                      TextField(
                        focusNode: focusNode,
                        controller: commentController,
                        maxLines: 2,
                        keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          isDense: true,
                          labelText: postQuery.data?.type == PostType.question
                              ? 'Answer'
                              : 'Comment',
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
              ),
            );
          }),
        ],
      ),
    );
  }
}
