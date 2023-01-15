import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/components/image/avatar.dart';
import 'package:eusc_freaks/components/posts/post_card.dart';
import 'package:eusc_freaks/components/scrolling/waypoint.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:eusc_freaks/queries/posts.dart';
import 'package:eusc_freaks/utils/platform.dart';
import 'package:eusc_freaks/utils/snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

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
    final mounted = useIsMounted();

    final posts = userPostsQuery.pages
        .map((page) => page?.items ?? [])
        .expand((element) => element)
        .toList();

    final tableStyle = Theme.of(context).textTheme.caption!;
    final tableHeaderStyle = tableStyle.copyWith(
      fontWeight: FontWeight.bold,
    );

    return Scaffold(
      body: Waypoint(
        controller: controller,
        onTouchEdge: () {
          if (userPostsQuery.hasNextPage) {
            userPostsQuery.fetchNextPage();
          }
        },
        child: RefreshIndicator(
          onRefresh: userPostsQuery.refetchPages,
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              const Gap(50),
              HookBuilder(builder: (context) {
                final avatarEditMode = useState(false);
                return MouseRegion(
                  onEnter: (event) {
                    avatarEditMode.value = true;
                  },
                  onExit: (event) {
                    avatarEditMode.value = false;
                  },
                  child: GestureDetector(
                    onTap: () {
                      if (kIsMobile) {
                        avatarEditMode.value = !avatarEditMode.value;
                      }
                    },
                    child: Stack(
                      children: [
                        Center(
                          child: Avatar(user: user, radius: 50),
                        ),
                        if (avatarEditMode.value)
                          Center(
                            child: CircleAvatar(
                              radius: 52,
                              backgroundColor: Colors.black45,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.image_outlined),
                                    onPressed: () async {
                                      final file =
                                          await FilePicker.platform.pickFiles(
                                        dialogTitle:
                                            "Select an profile picture",
                                        type: FileType.image,
                                        allowedExtensions: [
                                          'jpg',
                                          'png',
                                          'jpeg'
                                        ],
                                      );
                                      if (file == null || file.files.isEmpty) {
                                        avatarEditMode.value = false;
                                        return;
                                      }

                                      await pb.collection('users').update(
                                        user.id,
                                        files: [
                                          await MultipartFile.fromPath(
                                            'avatar',
                                            file.files.first.path!,
                                            filename: file.files.first.name,
                                            contentType: MediaType(
                                              'image',
                                              file.files.first.extension!,
                                            ),
                                          ),
                                        ],
                                      );
                                      await ref
                                          .read(authenticationProvider.notifier)
                                          .refetch();
                                      avatarEditMode.value = false;
                                      if (mounted()) {
                                        showSnackbar(
                                          context,
                                          'Profile picture updated. Restart the app to see the changes',
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () async {
                                      await pb.collection('users').update(
                                        user.id,
                                        body: {
                                          'avatar': null,
                                        },
                                      );
                                      await ref
                                          .read(authenticationProvider.notifier)
                                          .refetch();
                                      avatarEditMode.value = false;
                                      if (mounted()) {
                                        showSnackbar(
                                          context,
                                          'Profile picture removed. Restart the app to see the changes',
                                          backgroundColor: Colors.red[400],
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const Gap(20),
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
                    if (!user.isMaster) ...[
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
                            TableRow(
                              children: [
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Year',
                                      style: tableHeaderStyle,
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Class',
                                      style: tableHeaderStyle,
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Roll',
                                      style: tableHeaderStyle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ...user.sessionObjects.map((session) {
                              return TableRow(children: [
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      session.year.toString(),
                                      style: tableStyle,
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      session.standard.toString(),
                                      style: tableStyle,
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      session.serial.toString(),
                                      style: tableStyle,
                                    ),
                                  ),
                                ),
                              ]);
                            }).toList(),
                          ],
                        ),
                      ),
                    ] else ...[
                      ListTile(
                        title: const Text('Subject'),
                        subtitle: Text(
                            user.currentSession?.subject?.formattedName ?? ""),
                      ),
                      ListTile(
                        title: const Text('Joining Year'),
                        subtitle:
                            Text(user.currentSession?.year.toString() ?? ""),
                      ),
                      ListTile(
                        title: const Text('ID No.'),
                        subtitle:
                            Text(user.currentSession?.serial.toString() ?? ""),
                      ),
                    ]
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
      ),
    );
  }
}
