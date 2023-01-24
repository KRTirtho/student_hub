import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/models/notification.dart';
import 'package:fl_query/fl_query.dart';
import 'package:pocketbase/pocketbase.dart';

final notificationsQueryJob =
    InfiniteQueryJob<ResultList<Notification>, String?, int>(
  queryKey: "notifications-query",
  initialParam: 1,
  getNextPageParam: (lastPage, pages) =>
      lastPage.items.length < lastPage.perPage ? null : lastPage.page + 1,
  getPreviousPageParam: (firstPage, pages) => firstPage.page - 1,
  refetchOnMount: true,
  task: (queryKey, pageParam, userId) async {
    final res = await pb.collection("notifications").getList(
          page: pageParam,
          expand: "user",
          perPage: 10,
          filter: "user = '$userId'",
          sort: "viewed,-created",
        );

    return ResultList(
      items: await Future.wait(res.items.map((e) async {
        switch (NotificationCollection.fromName(e.data["collection"])) {
          case NotificationCollection.comments:
            e.expand["comment"] = [
              await pb
                  .collection("comments")
                  .getOne(e.data["record"], expand: "post,post.user")
            ];
            break;
          case NotificationCollection.posts:
            e.expand["post"] = [
              await pb.collection("posts").getOne(e.data["record"])
            ];
            break;
          default:
        }
        return Notification.fromRecord(e);
      })),
      page: res.page,
      perPage: res.perPage,
      totalItems: res.totalItems,
      totalPages: res.totalPages,
    );
  },
);
