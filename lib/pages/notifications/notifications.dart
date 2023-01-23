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
            constraints: const BoxConstraints(maxWidth: 400),
            alignment: Alignment.center,
            separatorBuilder: (context, index) => const Gap(8),
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final notification = notifications[index];

              return Card(
                color: notification.viewed
                    ? Theme.of(context).cardColor
                    : cardActiveColor,
                child: ListTile(
                  title: Text(
                    notification.message,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  dense: true,
                  subtitle: Text(format(DateTime.parse(notification.created))),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
