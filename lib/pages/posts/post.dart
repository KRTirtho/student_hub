import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/components/posts/post_card.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:eusc_freaks/queries/posts.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:readmore/readmore.dart';
import 'package:timeago/timeago.dart';

class PostPage extends HookConsumerWidget {
  final String postId;
  const PostPage({Key? key, required this.postId}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final postQuery = useQuery(job: postQueryJob(postId), externalData: null);
    final commentController = useTextEditingController();
    final updating = useState(false);

    void comment() async {
      if (commentController.text.isEmpty) return;
      updating.value = true;

      await pb.collection("comments").create(body: {
        "comment": commentController.text.trim(),
        "post": postId,
        "user": ref.read(authenticationProvider)?.id,
      });
      commentController.clear();
      await postQuery.refetch();
      updating.value = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Post"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(8),
            children: [
              if (postQuery.hasData && !postQuery.hasError) ...[
                PostCard(post: postQuery.data!, expanded: true),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Comments",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
                ...postQuery.data!.comments.map(
                  (comment) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(radius: 8),
                                const Gap(5),
                                Text(
                                  comment.user!.name ?? comment.user!.username,
                                  style:
                                      Theme.of(context).textTheme.labelMedium!,
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
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ] else if (postQuery.hasError &&
                  postQuery.error is ClientException)
                Center(
                  child: Text(
                    (postQuery.error as ClientException).response["message"],
                  ),
                )
              else
                const Center(child: CircularProgressIndicator.adaptive()),
              const Gap(60),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: commentController,
                onSubmitted: (_) => comment(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).backgroundColor,
                  isDense: true,
                  labelText: 'Comment',
                  suffix: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: updating.value ? null : comment,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
