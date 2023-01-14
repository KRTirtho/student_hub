import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/models/post.dart';
import 'package:fl_query/fl_query.dart';
import 'package:pocketbase/pocketbase.dart';

final postsInfiniteQueryJob =
    InfiniteQueryJob.withVariableKey<ResultList<Post>, void, int>(
  preQueryKey: "posts-query",
  initialParam: 1,
  getNextPageParam: (lastPage, pages) =>
      lastPage.items.length < lastPage.perPage ? null : lastPage.page + 1,
  getPreviousPageParam: (firstPage, pages) => firstPage.page - 1,
  task: (queryKey, pageParam, type) async {
    final types = getVariable(queryKey).split(",");

    final filter = types.map((type) => "type = '$type'").join(" || ");
    final res = await pb.collection("posts").getList(
          page: pageParam,
          perPage: 5,
          expand: "user",
          filter: filter,
        );
    return ResultList(
      items: res.items.map((r) => Post.fromRecord(r)).toList(),
      page: res.page,
      perPage: res.perPage,
      totalItems: res.totalItems,
      totalPages: res.totalPages,
    );
  },
);

final postQueryJob = QueryJob.withVariableKey<Post, void>(
  preQueryKey: "post-query",
  task: (queryKey, externalData) async {
    final res = await pb
        .collection("posts")
        .getOne(getVariable(queryKey), expand: "user,comments(post).user");

    return Post.fromRecord(res);
  },
);
