import 'package:eusc_freaks/collections/pocketbase.dart';
import 'package:eusc_freaks/components/image/avatar.dart';
import 'package:eusc_freaks/components/posts/post_card.dart';
import 'package:eusc_freaks/components/scrolling/waypoint.dart';
import 'package:eusc_freaks/providers/authentication_provider.dart';
import 'package:eusc_freaks/queries/posts.dart';
import 'package:eusc_freaks/queries/user.dart';
import 'package:eusc_freaks/utils/snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';

class ProfilePage extends HookConsumerWidget {
  final String userId;
  const ProfilePage({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    final controller = useScrollController();
    final authUser = ref.watch(authenticationProvider);
    final userQuery = useQuery(
      job: userQueryJob(userId),
      externalData: authUser,
    );
    final mounted = useIsMounted();
    final isOwner =
        userId == "authenticated" || userQuery.data?.id == authUser?.id;

    final tableStyle = Theme.of(context).textTheme.caption!;
    final tableHeaderStyle = tableStyle.copyWith(
      fontWeight: FontWeight.bold,
    );

    Future<void> updateProfilePicture() async {
      final file = await FilePicker.platform.pickFiles(
        dialogTitle: "Select an profile picture",
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg'],
      );
      if (file == null || file.files.isEmpty) {
        return;
      }

      await pb.collection('users').update(
        userQuery.data!.id,
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
      await ref.read(authenticationProvider.notifier).refetch();
      if (mounted()) {
        showSnackbar(
          context,
          'Profile picture updated. Restart the app to see the changes',
        );
      }
    }

    return Scaffold(
      appBar: GoRouter.of(context).canPop()
          ? AppBar(
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
            )
          : null,
      extendBodyBehindAppBar: true,
      body: !userQuery.hasData
          ? const Center(child: CircularProgressIndicator())
          : HookBuilder(builder: (context) {
              final userPostsQuery = useInfiniteQuery(
                job: userPostsInfiniteQueryJob(userQuery.data!.id),
                externalData: null,
              );
              final posts = userPostsQuery.pages
                  .map((page) => page?.items ?? [])
                  .expand((element) => element)
                  .toList();

              final avatarURL = userQuery.data!.getAvatarURL();
              return Waypoint(
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
                      Stack(
                        children: [
                          Center(
                            child: Avatar(
                              user: userQuery.data!,
                              radius: 50,
                              tag: avatarURL,
                              onTap: () {
                                GoRouter.of(context).push(
                                  '/media/image',
                                  extra: [avatarURL],
                                );
                              },
                            ),
                          ),
                          if (isOwner)
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.image_outlined),
                                      color: Colors.black,
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.white60,
                                      ),
                                      onPressed: updateProfilePicture,
                                    ),
                                    const Gap(5),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      color: Colors.red[400],
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.white60,
                                      ),
                                      onPressed: () async {
                                        await pb.collection('users').update(
                                          userQuery.data!.id,
                                          body: {
                                            'avatar': null,
                                          },
                                        );
                                        await ref
                                            .read(
                                                authenticationProvider.notifier)
                                            .refetch();
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
                      const Gap(20),
                      if (userQuery.data!.name != null)
                        Center(
                          child: Text(
                            userQuery.data!.name!,
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
                              subtitle: Text(userQuery.data!.email),
                            ),
                            ListTile(
                              title: const Text('Username'),
                              subtitle: Text(userQuery.data!.username),
                            ),
                            if (!userQuery.data!.isMaster) ...[
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
                                    ...userQuery.data!.sessionObjects
                                        .map((session) {
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
                                  userQuery.data!.currentSession?.subject
                                          ?.formattedName ??
                                      "",
                                ),
                              ),
                              ListTile(
                                title: const Text('Joining Year'),
                                subtitle: Text(
                                  userQuery.data!.currentSession?.year
                                          .toString() ??
                                      "",
                                ),
                              ),
                              ListTile(
                                title: const Text('ID No.'),
                                subtitle: Text(
                                  userQuery.data!.currentSession?.serial
                                          .toString() ??
                                      "",
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                      const Gap(10),
                      Text(
                        isOwner
                            ? "Your Posts"
                            : "${userQuery.data!.name}'s Posts",
                        style: Theme.of(context)
                            .textTheme
                            .caption
                            ?.copyWith(fontSize: 18),
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
            }),
    );
  }
}
