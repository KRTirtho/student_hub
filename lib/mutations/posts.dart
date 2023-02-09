import 'package:student_hub/collections/pocketbase.dart';
import 'package:student_hub/models/post.dart';
import 'package:fl_query/fl_query.dart';

final postCommentMutationJob = MutationJob<Post, Map<String, dynamic>>(
  mutationKey: "post-comment",
  task: (queryKey, variables) async {
    return Post.fromRecord(
      await pb.collection("comments").create(body: variables),
    );
  },
);
