import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/models/post.dart';
import 'package:fl_query/fl_query.dart';

final postCommentMutationJob = MutationJob<Post, Map<String, dynamic>>(
  mutationKey: "post-comment",
  task: (queryKey, variables) async {
    return Post.fromRecord(
      await pb.collection("comments").create(body: variables),
    );
  },
);
