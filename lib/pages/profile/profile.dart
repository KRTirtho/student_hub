import 'package:eusc_freaks/components/image/avatar.dart';
import 'package:eusc_freaks/components/posts/post_card.dart';
import 'package:eusc_freaks/components/scrolling/waypoint.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:eusc_freaks/queries/posts.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = useScrollController();
    final user = ref.watch(authenticationProvider);
    final userPostsQuery = useInfiniteQuery(
      job: userPostsInfiniteQueryJob(user!.id),
      externalData: null,
    );

    final posts = userPostsQuery.pages
        .map((page) => page?.items ?? [])
        .expand((element) => element)
        .toList();

    return Scaffold(
      body: Waypoint(
        controller: controller,
        onTouchEdge: () {
          if (userPostsQuery.hasNextPage) {
            userPostsQuery.fetchNextPage();
          }
        },
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            Avatar(user: user, radius: 50),
            if (user.name != null)
              Center(
                child: Text(
                  user.name!,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
            const Gap(70),
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text('Email'),
                    subtitle: Text(user.email),
                  ),
                  ListTile(
                    title: const Text('Username'),
                    subtitle: Text(user.username),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      'Sessions',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Table(
                      children: [
                        const TableRow(
                          children: [
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Year'),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Class'),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('Roll'),
                              ),
                            ),
                          ],
                        ),
                        ...user.sessionObjects.map((session) {
                          return TableRow(children: [
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(session.year.toString()),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(session.standard.toString()),
                              ),
                            ),
                            TableCell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(session.serial.toString()),
                              ),
                            ),
                          ]);
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Gap(10),
            Text(
              "Your Posts",
              style:
                  Theme.of(context).textTheme.caption?.copyWith(fontSize: 18),
            ),
            ...posts.map(
              (post) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: PostCard(post: post),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
