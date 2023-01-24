import 'package:badges/badges.dart';
import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/components/scrolling/constrained_list_view.dart';
import 'package:eusc_freaks/components/scrolling/waypoint.dart';
import 'package:eusc_freaks/hooks/use_brightness_value.dart';
import 'package:eusc_freaks/models/notification.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:eusc_freaks/queries/notifications.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:timeago/timeago.dart';

class NotificationsPage extends HookConsumerWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = useScrollController();
    final notificationsQuery = useInfiniteQuery(
      job: notificationsQueryJob,
      externalData: ref.watch(authenticationProvider)?.id,
    );

    final notifications = notificationsQuery.pages
        .expand<Notification>((page) => [
              ...?page?.items.toList(),
            ])
        .toList();

    final unreadNotifications =
        notifications.where((notification) => !notification.viewed).toList();
    final cardActiveColor =
        useBrightnessValue(Colors.blue[100], Colors.lightBlue[900]);

    final commentIconColor = {
      "announcement": {
        "fg": Colors.orange[200],
        "bg": Colors.red[400],
      },
      "comment-add": {
        "fg": Colors.indigo,
        "bg": Colors.blue[200],
      },
      "comment-solved": {
        "fg": Colors.green[900],
        "bg": Colors.green[100],
      }
    };

    final GoRouter router = GoRouter.of(context);

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text("Notifications"),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).textTheme.caption?.color,
                ),
                const Gap(4),
                Text(
                  "You've ${unreadNotifications.length} unread notifications",
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          )),
      body: Waypoint(
        controller: controller,
        onTouchEdge: () {
          if (notificationsQuery.hasNextPage) {
            notificationsQuery.fetchNextPage();
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            await notificationsQuery.refetchPages();
          },
          child: ConstrainedListView.separated(
            controller: controller,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: notifications.length,
            constraints: const BoxConstraints(maxWidth: 600),
            alignment: Alignment.center,
            separatorBuilder: (context, index) => const Gap(5),
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final notification = notifications[index];

              Widget leading;

              switch (notification.collection) {
                case NotificationCollection.comments:
                  if (notification.comment?.post?.user?.id ==
                      ref.read(authenticationProvider)?.id) {
                    leading = CircleAvatar(
                      backgroundColor: commentIconColor["comment-add"]?["bg"],
                      child: Icon(
                        Icons.add_comment_outlined,
                        color: commentIconColor["comment-add"]?["fg"],
                      ),
                    );
                    break;
                  }
                  leading = CircleAvatar(
                    backgroundColor: commentIconColor["comment-solved"]?["bg"],
                    child: Icon(
                      Icons.check_circle_outline,
                      color: commentIconColor["comment-solved"]?["fg"],
                    ),
                  );
                  break;
                case NotificationCollection.posts:
                  leading = CircleAvatar(
                    backgroundColor: commentIconColor["announcement"]?["bg"],
                    child: Icon(
                      Icons.campaign_outlined,
                      color: commentIconColor["announcement"]?["fg"],
                    ),
                  );
                  break;
                default:
                  leading = const Icon(Icons.info);
              }

              return Card(
                color: notification.viewed ? null : cardActiveColor,
                child: ListTile(
                  leading: leading,
                  title: Badge(
                    badgeColor: Colors.blue,
                    alignment: Alignment.centerLeft,
                    showBadge: !notification.viewed,
                    child: Text(
                      notification.message,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  dense: true,
                  onTap: () async {
                    final rec = await pb.collection("notifications").update(
                      notification.id,
                      body: {
                        "viewed": true,
                      },
                    );

                    if (rec.data["viewed"] != true) return;
                    await notificationsQuery.refetchPages();

                    switch (notification.collection) {
                      case NotificationCollection.comments:
                        router.push(
                          '/posts/${notification.comment?.post?.id}?comment=${notification.comment?.id}',
                        );
                        break;
                      case NotificationCollection.posts:
                        router.push(
                          '/posts/${notification.post?.id}',
                        );
                        break;
                      default:
                    }
                  },
                  subtitle: Text(
                    format(DateTime.parse(notification.created)),
                    textAlign: TextAlign.end,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
